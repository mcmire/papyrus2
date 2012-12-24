
require 'set'

#require 'papyrus/sub'
#require 'papyrus/block_command'

module Papyrus
  # A Command is a Node that represents a substitution in the source template
  # where the sub is not simply a variable, but more like a function, i.e., it
  # can accept arguments and you have much greater control over the return
  # value.
  #
  # Note that there's some leftover code from when I was first working on block
  # commands here. We don't currently use this but we may in the future.
  #
  class Command < Sub
    # Get the list of command modifiers for this Command class.
    #
    def self.modifiers
      @modifiers ||= Set.new
    end

    # Define a modifier by defining a method by the given name and adding the
    # modifier to the list of modifiers.
    #
    def self.modifier(name, &block)
      name = name.to_sym
      define_method(name, &block)
      self.modifiers << name
    end

    # Get the list of aliases for this Command class.
    #
    def self.aliases
      @aliases ||= Set.new
    end

    # Define aliases for this command.
    #
    def self.aka(*aliases)
      self.aliases # init set
      @aliases += aliases
    end

    attr_reader :name, :args

    # If this command is a BlockCommand, and this command has a method with the
    # same name as the given modifier, the method is called and its return value
    # is returned. Otherwise, false is returned.
    #
    # This is used by Parser to both check and run a modifier on the currently
    # active command.
    #
    def modified_by?(modifier, args)
      is_a?(BlockCommand) or return false
      respond_to?(modifier) or return false
      send(modifier, args)
    end
  end
end

