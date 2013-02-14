# For most commands, the task of evaluation is simple: figure out how to
# turn oneself into a string and then return that string. For variables and the
# `[include]` built-in command, however, a bit more logic is required. These
# subs are special because they affect the parent document: upon being
# evaluated, they actually end up replacing themselves with their contents.
# This module provides this ability and is always mixed into a Sub of some kind.
#
module Papyrus
  module InsertionSub
    # Given we are in the middle of evaluating a node list, and the loop is on a
    # certain node, **#parse_and_insert_into_parent** takes some text, runs it
    # through the parser to obtain another set of nodes, and then replaces the
    # original node with this new set of nodes.
    #
    # ||Arguments:||
    #
    # * `content` -- The String text that will be parsed. For a variable this
    #   is its raw value, for `[include]` this is the raw content of the
    #   referenced template.
    #
    def parse_and_insert_into_parent(content)
      return "" if content.to_s.empty?

      # First, make a new Template that will house the `content` (using the same
      # options that this Template was initialized with), and then run the
      # `content` through the Parser to obtain a new Document (a tree of Nodes).
      template = self.template.clone_with(content, {}, self)
      document = template.analyze

      # Recall that this Sub has been asked to evaluate itself by the
      # surrounding NodeList and is waiting for an answer. If there aren't any
      # subs in the content, then the answer, the result of the evaluation, is
      # the evaluation of the list of Nodes generated in the previous step.
      return document.evaluate.join if document.nodes.all? {|node| Text === node }

      # If, however, there are subs, then we need to ask the surrounding
      # NodeList to swap out this Sub with all of the Nodes from the previous
      # step; from here the NodeList will resume evaluating itself *as though
      # these Nodes were there all along, starting with the first Node*.
      klass = (Variable === self && name == "body") ? BodyNodeList : NodeList
      self.parent.expand_current(document.nodes, klass)
      raise RedoEvaluation
    end
  end
end
