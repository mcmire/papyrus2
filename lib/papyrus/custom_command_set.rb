
#require 'papyrus/errors'

module Papyrus
  # Custom commands are those which give you more flexibility over builtins as
  # they let you define any methods you want in a wrapper class that you can
  # then mix into Papyrus's lexicon at runtime. If a command is encountered in
  # the template Papyrus will look for a corresponding method in the wrapper
  # class, calling it with the arguments of the command.
  #
  # Your wrapper class must inherit from CustomCommandSet, and then you pass an
  # instance of it to the Parser using its :custom_commands option.
  #
  # Custom commands can either be inline or block commands, which are located as
  # methods in a InlineCommands or BlockCommands module, respectively, inside
  # your wrapper class.
  #
  class CustomCommandSet
    def self.command_properties
      @command_properties ||= Hash.new { |h, k| h[k] = Hash.new }
    end

    def self.aliases
      @aliases ||= Hash.new
    end

    # TODO: This should be reversed
    def self.alias_command(name, alias_name)
      aliases[_convert_name(alias_name)] = _convert_name(name)
    end

    def self.dont_pre_evaluate_args(*names)
      names.each do |name|
        command_properties[_convert_name(name)][:pre_evaluate_args] = false
      end
    end

    def self.has_inline_command?(name)
      return false unless const_defined?(:InlineCommands)
      name = _convert_name(name)
      real_name = aliases[name] || name
      const_get(:InlineCommands).instance_methods.include?(real_name)
    end

    def self.has_block_command?(name)
      return false unless const_defined?(:BlockCommands)
      name = _convert_name(name)
      real_name = aliases[name] || name
      const_get(:BlockCommands).instance_methods.include?(real_name)
    end

    def self._convert_name(name)
      name.to_sym.downcase
    end

    attr_reader :template, :args, :inner

    # Creates a new CustomCommandSet, storing the parser the CustomCommandSet
    # belongs to and the arguments to the command.
    #
    def initialize(template, args=nil)
      @template = template
      @args = args || {}

      # Include the modules if they were defined
      if self.class.const_defined?(:InlineCommands)
        extend self.class.const_get(:InlineCommands)
      end
      if self.class.const_defined?(:BlockCommands)
        extend self.class.const_get(:BlockCommands)
      end
    end

    # Called on #dup or #clone.
    #
    def initialize_copy(set)
      @args = @args.clone

      # Include the modules if they were defined
      if self.class.const_defined?(:InlineCommands)
        extend self.class.const_get(:InlineCommands)
      end
      if self.class.const_defined?(:BlockCommands)
        extend self.class.const_get(:BlockCommands)
      end
    end

    # Attempts to look up the given inline command and call it. If the command
    # is not defined, #inline_command_missing is called instead.
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

    # Attempts to look up the given block command and call it. If the command
    # is not defined, #block_command_missing is called instead.
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

    # Called by the Parser if the inline command attempted to be called but was
    # not defined. Override to customize behavior. Remember to raise
    # UnknownSubError or ParserError if an error is encountered!
    #
    def inline_command_missing(name, args)
      raise UnknownSubError
    end

    # Called by the Parser if the block command attempted to be called but was
    # not defined. Override to customize behavior. Remember to raise
    # UnknownSubError or ParserError if an error is encountered!
    #
    def block_command_missing(name, args, inner)
      raise UnknownSubError
    end
  end
end

