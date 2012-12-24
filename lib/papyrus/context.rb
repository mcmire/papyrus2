
#require 'papyrus/context_item'

module Papyrus
  # A Context is a simple ContextItem.
  #
  class Context
    include ContextItem

    # Create a new Context, merging the given hash with the context's variables.
    #
    def self.construct_from(hash)
      context = Context.new
      context.vars = hash
      context
    end

    # Create a new Context, storing the optional parent and object, which
    # may be used later when accessing context variables.
    #
    def initialize(parent=nil, object=nil)
      @parent = parent
      @object = object
      @vars = {}
    end

    attr_reader :parent
    attr_reader :object
  end
end
