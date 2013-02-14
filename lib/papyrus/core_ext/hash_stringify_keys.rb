# This file opens the Hash class and defines two methods, `#stringify_keys` and
# `#stringify_keys!`. These methods encapsulate the pattern of transforming a
# hash by converting all of its keys from Symbols to Strings.
#
class Hash
  unless method_defined?(:stringify_keys)
    def stringify_keys
      inject({}) {|hash,(k,v)| hash[k.to_s] = v; hash }
    end
  end

  unless method_defined?(:stringify_keys!)
    def stringify_keys!
      replace(stringify_keys)
    end
  end
end
