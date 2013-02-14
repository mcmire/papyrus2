# Node is the base class of all objects within a Document (the AST
# representation of parsed text). A Node is something -- a single object such
# as a Command or Variable, or a group of objects such as a NodeList -- that can
# be *evaluated*. This basically means converting the Node into a String.
# Different types of Nodes have specific logic to do this, but all nodes have an
# \#evaluate method.  If the Node is a Sub or Variable, then we sometimes
# describe it as being *resolved*. Finally, owing to the "tree" part of the AST,
# Nodes may be tied to other nodes via a `parent` relationship.

require 'forwardable'

module Papyrus
  class Node
    extend Forwardable

    # ## Public methods

    # **Node#parent** is the parent Node this Node is tied to.
    attr_accessor :parent

    # **Node#old_parent** -- If a NodeList is grafted into another via
    # InsertionSub, all of the Nodes therein have new parents; however, any old
    # references those Nodes may have had to each other are retained.
    # `old_parent` is a reference to the `parent` before the grafting.
    attr_accessor :old_parent

    # **Node#document** is the root Document object where the Node ultimately
    # lives (even if it first lives in a NodeList). A Node doesn't usually have
    # an immediate reference to this object, so ascend the tree until we reach a
    # Node that does. (We do it this way so that if the Node is transplanted
    # into another Document, we don't have to explicitly reset this reference.)
    delegate [:document] => :parent

    # **Node#parser** is the Parser that created the Document.
    delegate [:parser] => :document

    # **Node#template** is the Template object that's tied to the Parser.
    delegate [:template] => :parser

    # **Node#evaluate** converts the Node to text form. Different subclasses of
    # Node override this to accomplish this in different ways.
    #
    # Returns a String, except in the case of NodeList where it returns an
    # Array of Strings.
    #
    def evaluate
      raise NotImplementedError, 'Node#evaluate must be implemented by a subclass'
    end

    # **Node#get** retrieves a value from a parent context. A Node usually has
    # no concept of a context and therefore cannot hold values, but the parent
    # Node may, so ask that instead.
    delegate :get => :parent

    # ## Internal methods

    # **Node#pretty_print_instance_variables** controls which data to include in
    # the PrettyPrint (pp) version of the object. Certain objects are rather
    # verbose when pretty printed, so exclude these from the output.
    #
    def pretty_print_instance_variables
      self.instance_variables.sort - ['@document', '@parser', '@template', '@parent']
    end
  end
end
