# The Lexicon holds all of the commands that Papyrus knows about. When the
# Parser goes to resolve a sub as a command, it will look in the Lexicon.
#
# Adding a (built-in) command to the Lexicon requires that you make a wrapper
# class for the command. For instance, if you made a `[time]` command that
# outputs the current time, you might have a corresponding Time class that
# looked something like:
#
# ~~~ ruby
# module MyCommands
#   class Time < Papyrus::Command
#     def evaluate
#       # ...
#     end
#   end
# end
# ~~~
#
# Then, you could add it to the Lexicon as follows:
#
# ~~~ ruby
# Papyrus::Lexicon.add_command(:time, MyCommands::Time)
# ~~~
#
# Or, if you had a whole collection of classes, you could add them in one fell
# swoop by saying:
#
# ~~~ ruby
# Papyrus::Lexicon.extend_lexicon(MyCommands)
# ~~~
#
# In fact, this is what Papyrus uses to add its own built-in commands.
#
# NOTE: If you wish to define methods in terms of methods rather than
# full-on Command classes, the Lexicon does not support this; instead, use a
# CustomCommandSet. Read the document on that for more information. Perhaps this
# will be combined at a later time.
#
module Papyrus
  class Lexicon
    # ## Public methods

    # **Lexicon.add_command** lets you add a single command (represented by a
    # class) to the lexicon.
    #
    # ||Arguments:||
    #
    # * `name` -- The String or Symbol name of the new command.
    # * `klass` -- A Class constant which contains the logic for this command
    # (expected to be a subclass of Papyrus::Command).
    #
    def self.add_command(name, klass)
      name = name.to_sym
      commands[name] = klass
    end

    # **Lexicon.extend_lexicon** lets you add a group of commands (represented
    # by classes contained in a namespace) to the lexicon all at once.
    #
    # ||Arguments:||
    #
    # * `mod` - The Module constant which contains classes. These classes are
    # expected to be subclasses of Papyrus::Command. The name of each command
    # is derived from the name of the class (so a Time class would be assumed to
    # represent the `[time]` command).
    #
    def self.extend_lexicon(mod)
      return if extensions.include?(mod)
      mod.constants.each do |constant|
        command_name = constant.downcase
        command_class = mod.const_get(constant)
        if Class === command_class
          add_command(command_name, command_class)
        end
      end
      extensions << mod
    end

    # ## Internal methods

    # **Lexicon.commands** contains all of the defined commands (whether defined
    # individually or from a module).
    #
    # Returns a Hash of \<Symbol command name, Class command class\>.
    #
    def self.commands
      @commands ||= {}
    end

    # **Lexicon.extensions** contains all of the modules which have been used to
    # extend the lexicon. This is really just used to ensure that a module is
    # not used to extend the lexicon more than once.
    #
    # Returns an Array of Modules.
    #
    def self.extensions
      @extensions ||= []
    end
  end
end
