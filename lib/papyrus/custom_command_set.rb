# Papyrus comes with some builtin commands, but we recognize that you may have
# your own commands that you want to add to the Papyrus lexicon. The way you do
# this is through a CustomCommandSet. The idea is that commands correspond to
# instance methods inside of a CustomCommandSet, and when Papyrus resolves a
# command it will look for a corresponding method by the same name and call it
# if it exists.
#
# CustomCommandSet is an abstract class, so to start out you must make your own
# class that inherits from it. As you may know there are two types of commands,
# inline and block, and you can define both.
#
# * To define inline commands, open an InlineCommands module inside of your
#   class. Any methods you define in this module will be seen as inline
#   commands. When called, each method receives one argument: the list of
#   arguments given to the command as an Array of {Array | String}. (A nested
#   array will appear if a sub was passed in as one of the arguments to the
#   command. You will likely want to flatten this array and work with it from
#   there.) Each method you define must return a String.
#
# * Similarly, for block commands use a BlockCommands module, and any methods
#   you define here will be seen as block commands. When called, they receive
#   two arguments: the command's argument list as an Array, and the contents of
#   the command as a String. Again, each method you define must return a String.
#
# Both modules are mixed into your CustomCommandSet, so if you need to refer to
# methods that are not intended to be commands, define them outside of the
# modules.
#
# Speaking of outside the modules, you can use `alias_command` and
# `dont_pre_evaluate_args` to modify properties about any commands.
#
# Finally, to hook your class into Papyrus, you tell the Template about it
# using a `:custom_commands_class` option.
#
# Here is an example to show how all of this works:
#
# ~~~ ruby
# class MyCustomCommandSet < Papyrus::CustomCommandSet
#   module InlineCommands
#     # Show a formatted version of the current time.
#     #
#     # Syntax:
#     #   time [FORMAT]
#     #
#     # Examples:
#     #   [time]
#     #   [time "%Y%m%d"]
#     #
#     def time(args)
#       args = args.flatten
#       format = args.first || "%Y-%m-%d"
#       Time.now.strftime(format)
#     end
#   end
#
#   module BlockCommands
#     # Show the contents of the block only if the private flag is checked.
#     #
#     # Syntax:
#     #   [private]...[/private]
#     #
#     def private(args, inner)
#       show_private? ? inner : ""
#     end
#   end
#
#   dont_pre_evaluate_args :private
#
#   def show_private?
#     # ...
#   end
# end
#
# # Later...
#
# template = Papyrus::Template.new(some_content,
#   :custom_commands_class => MyCustomCommandSet
# )
# template.render
# ~~~
#
# TODO:
#
# * Instead of forcing the user to define methods explicitly called
#   InlineCommands and BlockCommands, use a DSL -- `inline_commands do ... end`
#   and `block_commands do ... end`
# * Aliases should be associated with each command type, not globally, as an
#   inline command and block command can share the same name
#
module Papyrus
  class CustomCommandSet
    # ## Class methods

    # ### Public methods

    # **CustomCommandSet.alias_command** lets users refer to a command by
    # another name.
    #
    # ||Arguments:||
    #
    # * `name` -- The String or Symbol name of the existing command.
    # * `alias_name` -- The String or Symbol name of the new command.
    #
    def self.alias_command(name, alias_name)
      # TODO: The arguments here should be reversed to align with `alias_method`.
      aliases[_convert_name(alias_name)] = _convert_name(name)
    end

    # **CustomCommandSet.dont_pre_evaluate_args**: Usually when Papyrus
    # evaluates a command, it evaluates the arguments that have been given to
    # that command before executing the command itself, and passes the evaluated
    # arguments to the method for the command. If for some reason you do not
    # want this to happen or you want to handle the evaluation yourself,
    # you can tell Papyrus to forgo evaluation with this method.
    #
    # ||Arguments:||
    #
    # * A variadic list of String or Symbol names of commands.
    #
    def self.dont_pre_evaluate_args(*names)
      names.each do |name|
        command_properties[_convert_name(name)][:pre_evaluate_args] = false
      end
    end

    # **CustomCommandSet.has_inline_command?** lets you determine whether an
    # inline command is present in this command set.
    #
    # ||Arguments:||
    #
    # * `name` -- The String or Symbol name of a command.
    #
    # Returns true if yes, else false.
    #
    def self.has_inline_command?(name)
      return false unless const_defined?(:InlineCommands)
      name = _convert_name(name)
      real_name = aliases[name] || name
      const_get(:InlineCommands).instance_methods.include?(real_name)
    end

    # **CustomCommandSet.has_inline_command?** lets you determine whether a
    # block command is present in this command set.
    #
    # ||Arguments:||
    #
    # * `name` -- The String or Symbol name of a command.
    #
    # Returns true if yes, else false.
    #
    def self.has_block_command?(name)
      return false unless const_defined?(:BlockCommands)
      name = _convert_name(name)
      real_name = aliases[name] || name
      const_get(:BlockCommands).instance_methods.include?(real_name)
    end

    # ### Internal methods

    # **CustomCommandSet.command_properties** keeps explicit settings for
    # certain commands (so far, `:dont_pre_evaluate_args` is the only setting).
    #
    # Returns a Hash: each key is the Symbol name of a command, each value is a
    # Hash itself (the settings for that command).
    #
    def self.command_properties
      @command_properties ||= Hash.new { |h, k| h[k] = Hash.new }
    end

    # **CustomCommandSet.aliases** keeps the alternate names of commands for
    # which `alias_command` has been called.
    #
    # Returns a Hash: each key is the Symbol name of a command, each value is
    # the Symbol name of the original command it points to.
    #
    def self.aliases
      @aliases ||= Hash.new
    end

    # ### Private methods

    def self._convert_name(name)
      name.to_sym.downcase
    end

    # ## Instance methods

    # ### Public methods

    # **CustomCommandSet.template** returns the Template object that this
    # command set is plugged into.
    #
    attr_reader :template

    # **CustomCommandSet.args** returns the set of `:extra` options passed to
    # the Template.
    #
    attr_reader :args

    # **CustomCommandSet.new** initializes a new CustomCommandSet.
    #
    # ||Arguments:||
    #
    # * `template` -- The Template object that this command set is plugged into.
    # * `args` -- The set of `:extra` options passed to the Template. Not used
    #   in CustomCommandSet proper, but you may use them as you wish (they just
    #   allow for customization of whatever you want).
    #
    def initialize(template, args=nil)
      @template = template
      @args = args || {}

      # Include the modules into this instance if they have been defined, this
      # way any references within command methods to methods within this
      # instance will work.
      if self.class.const_defined?(:InlineCommands)
        extend self.class.const_get(:InlineCommands)
      end
      if self.class.const_defined?(:BlockCommands)
        extend self.class.const_get(:BlockCommands)
      end
    end

    # **CustomCommandSet#initialize_copy** is called on #dup or #clone.
    #
    # ||Arguments:||
    #
    # * `set` -- The original CustomCommandSet object that is being copied.
    #
    def initialize_copy(set)
      @args = @args.clone

      # Include the modules into this instance if they have been defined, this
      # way any references within command methods to methods within this
      # instance will work.
      if self.class.const_defined?(:InlineCommands)
        extend self.class.const_get(:InlineCommands)
      end
      if self.class.const_defined?(:BlockCommands)
        extend self.class.const_get(:BlockCommands)
      end
    end

    # **CustomCommandSet#__call_inline_command__** attempts to look up the given
    # inline command and call it. If the command is not defined,
    # \#inline_command_missing is called instead.
    #
    # ||Arguments:||
    #
    # * `sub` -- A Sub object.
    #
    # Returns a String.
    #
    def __call_inline_command__(sub)
      name = sub.name.to_sym
      real_name = self.class.aliases[name] || name
      pre_evaluate_args = self.class.command_properties[name][:pre_evaluate_args] === false
      args = pre_evaluate_args ? sub.orig_args : sub.evaluated_args

      if self.class.has_inline_command?(name)
        self.send(name, args)
      else
        inline_command_missing(name, args)
      end
    end

    # **CustomCommandSet#__call_block_command__** attempts to look up the given
    # block command and call it. If the command is not defined,
    # \#block_command_missing is called instead.
    #
    # ||Arguments:||
    #
    # * `sub` -- A Sub object.
    #
    # Returns a String.
    #
    def __call_block_command__(sub)
      name = sub.name.to_sym
      real_name = self.class.aliases[name] || name
      pre_evaluate_args = self.class.command_properties[name][:pre_evaluate_args] === false
      args = pre_evaluate_args ? sub.orig_args : sub.evaluated_args
      inner = sub.evaluated_nodes

      if self.class.has_block_command?(name)
        self.send(name, args, inner)
      else
        block_command_missing(name, args, inner)
      end
    end

    # **CustomCommandSet#inline_command_missing** is called by the Parser if the
    # inline command was attempted to be called yet was not defined. By default
    # Papyrus will simply not substitute the command, but if you want to change
    # this behavior, simply override this method -- just remember to raise
    # UnknownSubError or ParserError if an error is encountered.
    #
    # ||Arguments:||
    #
    # * `name` -- The Symbol name of a command.
    # * `args` -- Either an Array of Strings or a NodeList.
    #
    def inline_command_missing(name, args)
      raise UnknownSubError
    end

    # **CustomCommandSet#block_command_missing** is called by the Parser if the
    # block command was attempted to be called yet was not defined. By default
    # Papyrus will simply not substitute the command, but if you want to change
    # this behavior, simply override this method -- just remember to raise
    # UnknownSubError or ParserError if an error is encountered.
    #
    # ||Arguments:||
    #
    # * `name` -- The Symbol name of a command.
    # * `args` -- Either an Array of Strings or a NodeList.
    #
    def block_command_missing(name, args, inner)
      raise UnknownSubError
    end
  end
end

