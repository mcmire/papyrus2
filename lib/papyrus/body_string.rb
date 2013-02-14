# A BodyString represents the result from evaluating the `[body]` variable. We
# have an explicit type for this so that if you need to distinguish
# BodyStrings from regular strings in a post processing step, you can.

#
module Papyrus
  class BodyString < String
    def inspect
      "BodyString(#{super})"
    end
  end
end
