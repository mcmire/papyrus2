# A Document represents the abstract syntax tree (AST) which the Parser creates
# after parsing a text document. That is, it is the object representation of the
# text document that was parsed, where the Document is the root object and the
# Node objects, which all point back to the Document, represent the various
# pieces of the document.
#
# For instance, take the following text document:
#
# ~~~
# My name is Billy. Today is [current_date]. I am [age_for_birthyear 2000] years
# old. My favorite color today is: [random "red" "blue" "orange" "yellow"].
# [supersecret]Don't eat the yellow snow!![/supersecret]
# ~~~
#
# This would be parsed into the following AST:
#
# ~~~
# Document
# * @nodes
#   - Text("My name is Billy. Today is ")
#   - InlineSub("current_date")
#   - Text(". I am ")
#   - InlineCommand("age_for_birthyear")
#     * @arguments
#       - Text("2000")
#   - Text(" years old. My favorite color today is: ")
#   - InlineCommand("random")
#     * @arguments
#       - Text("red")
#       - Text("blue")
#       - Text("orange")
#       - Text("yellow")
#   - Text(". ")
#   - BlockCommand("supersecret")
#      * @arguments
#          (empty)
#      * @inner
#        - Text("Don't eat the yellow snow!!")
# ~~~
#
# In order to convert a Document back into text form, it must be evaluated.
# When a Document is told to evaluate itself, it loops through all of the Nodes
# it contains and asks them to evaluate themselves.

require 'forwardable'

module Papyrus
  class Document < NodeList
    extend Forwardable

    # The Document has a place where you can set and retrieve values. Without
    # this, Variable nodes would always resolve to nothing.
    #
    # Note that including this module overrides #[] and #[]= in NodeList, and
    # also the #get that is in Node.
    #
    include ContextItem

    # ## Public interface

    # #### Document.new
    #
    # ||Arguments:||
    #
    # * `parser` -- The Parser object that created this Document.
    # * `nodes` -- *(Optional)* An Array of Nodes to populate the Document with.
    #   *(Default: [])*
    #
    def initialize(parser, nodes=[])
      @parser = parser
      super(nodes)
    end

    # ### Properties

    # #### parser
    #
    # *(read/write)* The Parser object that created this Document.
    #
    attr_accessor :parser

    # #### options
    #
    # *(read-only)* The Hash of options that the Template was initialized with.
    #
    # [TODO: remove]
    #
    delegate :options => :template

    # #### vars
    #
    # *(read-only)* The Hash of values which Variables may resolve to.
    #
    # [TODO: #vars here should be set on the Document level not the Template
    # level!]
    #
    delegate :vars => :template

    # #### document
    #
    # *(read-only)* Overrides Node#document, which points to the Document that
    # created the Node by ascending the tree. The Document object is the root of
    # the tree, so in this case we just have it return itself.
    #
    def document
      self
    end

    # ### Internal methods

    # #### Document#pretty_print_instance_variables
    #
    # Overriding Node#pretty_print_instance_variables, controls which data to
    # include in the PrettyPrint (pp) version of the object. Certain objects are
    # rather verbose when pretty printed, so exclude these from the output.
    #
    def pretty_print_instance_variables
      super - ['@parser', '@vars']
    end
  end
end
