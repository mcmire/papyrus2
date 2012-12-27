# A Command is a Node that represents a substitution in the source template,
# where the sub has a dynamic value rather than a static one. You can think of
# this type of sub as a function -- it can accept arguments and you naturally
# have much greater control over the return value.
#
# Note the concept of modifiers here -- this is intended for block commands.
#
require 'set'

module Papyrus
  class Command < Sub
    # **Command.modifiers** gets the list of command modifiers for this Command
    # class.
    #
    def self.modifiers
      @modifiers ||= Set.new
    end

    # **Command.modifier** defines a modifier by defining a method by the given
    # name and adding the modifier to the list of modifiers.
    #
    # * *name*: The String name of the modifier.
    # * *block*: The body of the method that will be created.
    #
    def self.modifier(name, &block)
      name = name.to_sym
      define_method(name, &block)
      self.modifiers << name
    end

    # **Command.aliases** gets the list of aliases for this Command class.
    #
    def self.aliases
      @aliases ||= Set.new
    end

    # **Command.aka** defines aliases for this command.
    #
    # * *aliases*: A variadic list of Symbols.
    #
    def self.aka(*aliases)
      self.aliases # init set
      @aliases += aliases
    end

    # **Command#name** is the Symbol name of the command.
    attr_reader :name

    # **Command#args** is the Array of String arguments passed to the command.
    attr_reader :args

    # **Command#modified_by?** determines whether a sub modifies the current
    # sub. This is used during the parsing process.
    #
    # * *modifier:* The Symbol name of a modifier.
    # * *args*: An Array of arguments to pass to the modifier sub in question,
    #   if it exists.
    #
    # It returns false if this sub is not a block command, or if this sub does
    # not have a method named after the modifier.
    #
    # Otherwise, it returns the return value of said method.
    #
    def modified_by?(modifier, args)
      is_a?(BlockCommand) or return false
      respond_to?(modifier) or return false
      send(modifier, args)
    end
    # *(fin)*
  end
end

