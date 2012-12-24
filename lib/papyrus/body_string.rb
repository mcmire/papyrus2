
module Papyrus
  class BodyString < String
    def inspect
      "BodyString(#{super})"
    end
  end
end
