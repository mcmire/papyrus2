# A block command has a start tag, an end tag, and possibly modifier tags. The
# content between tags may span multiple lines, and contain subs itself. For
# instance, here is a hypothetical `[show-unless-locked]` block command:
#
#     <p>Here is a sample sentence.</p>
#     [show-unless-locked]
#       <p>This text won't be shown if the post is locked.
#     [/show-unless-locked]
#
# Here is a more common `[if]...[else]...[end]` block that shows the concept
# of modifier tags:
#
#     [if some-condition]
#       <p>Show this</p>
#     [else]
#       <p>Show this instead</p>
#     [end]
#
# As this is just an abstract class, you should not interact with it directly
# but in a subclass instead. For instance, you might have a
# ShowUnlessLockedCommand class for the first example that inherits from this
# one.
#
# **NOTE:** Block commands aren't quite completed yet, there are some kinks to
# iron out. (Well there were when I was working on this. I can't remember for
# the life of me what they were.)
#
require 'forwardable'

module Papyrus
  class BlockCommand < Command
    extend Forwardable

    # A BlockCommand is also a context object, not so much for storing
    # values but for ease in retrieving them from ancestors.
    include ContextItem

    # **BlockCommand.new** creates a new instance of the BlockCommand.
    #
    # Raises a TypeError if you call BlockCommand.new directly.
    #
    def initialize(*args)
      if self.class == BlockCommand
        raise TypeError, 'BlockCommand.new should not be called directly'
      end
      super
    end

    # Since block commands have multiple blocks, and since one block is active
    # at a given time, you can interact with this block directly.
    delegate [:add, :<<] => :active_block

    # **BlockCommand#active_block** -- since BlockCommands have the ability to
    # contain multiple blocks, this method returns (at least in theory) the last
    # block that the parser has come across.
    #
    # You must define this method in your subclass of BlockCommand. It must
    # return a NodeList.
    #
    def active_block
      raise NotImplementedError, 'BlockCommand#active_block should be overridden by a subclass'
    end

    # **BlockCommand#to_s** is a convenience method.
    #
    def to_s
      "[ #{@name} ]"
    end
  end
end

