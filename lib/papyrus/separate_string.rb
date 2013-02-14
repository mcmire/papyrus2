# SeparateString is a convenience class for use by client code. It has special
# behavior attached to it, in that when evaluating a NodeList, a Node whose
# evaluation result is a SeparateString is guaranteed not to be concatenated to
# the result of another Node (see [NodeList#evaluate](node_list.html#section-NodeList#evaluate)).

module Papyrus
  class SeparateString < String
    def inspect
      "SeparateString(#{super})"
    end
  end
end

