
require 'forwardable'

#require 'papyrus/node_list'
#require 'papyrus/context_item'

module Papyrus
  # A Document represents the abstract syntax tree (AST) created during the
  # parsing process. It is responsible for evaluating the nodes in the AST and
  # converting them into a final string.
  #
  class Document < NodeList
    extend Forwardable

    # Note that this overrides #[] and #[]= in NodeList,
    # and also the #get that is in Node
    include ContextItem

    # Create a new Document, storing the parser the Document belongs to.
    #
    def initialize(parser, nodes=[])
      super(nodes)
      @parser = parser
    end

    attr_accessor :parser

    delegate [:template] => :parser
    delegate [:options, :vars] => :template

    def document
      self
    end

    def pretty_print_instance_variables
      super - ['@parser', '@vars']
    end
  end
end
