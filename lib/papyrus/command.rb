# A Command is a Node that represents a substitution in the source template,
# where the sub has a dynamic value rather than a static one. You can think of
# this type of sub as a function -- it can accept arguments and you naturally
# have much greater control over the return value.
#
# Note the concept of modifiers here. Although unused at the moment, this is
# intended down the road for block commands.

#
require 'set'

module Papyrus
  class Command < Sub
    # ## Public interface

    # #### Command.modifier
    #
    # Defines a modifier for this command, along with an instance method which
    # will hold the actions for the command.
    #
    # ||Arguments:||
    #
    # * `name` -- The String name of the modifier.
    # * `block` -- The body of the method that will be created.
    #
    def self.modifier(name, &block)
      name = name.to_sym
      define_method(name, &block)
      self.modifiers << name
    end

    # #### Command.aka
    #
    # Lets people use alternate names for this command.
    #
    # ||Arguments:||
    #
    # * A variadic list of Symbols.
    #
    def self.aka(*aliases)
      self.aliases # init set
      @aliases += aliases
    end

    # #### Command#name
    #
    # The Symbol name of the command.
    #
    attr_reader :name

    # #### Command#args
    #
    # The Array of String arguments passed to the command.
    #
    attr_reader :args

    # #### Command#modified_by?
    #
    # This is used by the Parser -- if it is inside a block command and it
    # encounters a sub that could be a modifier, this is how it checks that.
    #
    # ||Arguments:||
    #
    # * `modifier` -- The Symbol name of a modifier.
    # * `args` -- An Array of arguments to pass to the modifier sub in
    #   question, if it exists.
    #
    # Returns false if this sub is not a block command, or if this sub does
    # not have a method named after the modifier. Otherwise, returns whatever
    # the modifier method returns (hopefully something truthy).
    #
    def modified_by?(modifier, args)
      return false if not is_a?(BlockCommand)
      return false if not respond_to?(modifier)
      send(modifier, args)
    end


    # ## Internal interface

    # #### Command.modifiers
    #
    # Gives you access to the modifiers which have been so far for this command.
    #
    # Returns a Set of Symbols.
    #
    def self.modifiers
      @modifiers ||= Set.new
    end

    # #### Command.aliases
    #
    # Gives you access to the aliases that have been defined for this command.
    #
    # Returns a Set of Symbols.
    #
    def self.aliases
      @aliases ||= Set.new
    end
  end
end

