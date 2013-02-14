# A BodyNodeList represents the node list that comprises the contents of the
# `[body]` variable. We have an explicit type for this because
# NodeList#evaluate has special logic so that BodyNodeLists turn into
# BodyStrings instead of regular Strings.

#
module Papyrus
  class BodyNodeList < NodeList; end
end

