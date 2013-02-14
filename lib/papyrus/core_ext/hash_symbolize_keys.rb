# This file opens the Hash class and defines two methods, `#symbolize_keys` and
# `#symbolize_keys!`. These methods encapsulate the pattern of transforming a
# hash by converting all of its keys from Strings to Symbols.
#
class Hash
  unless method_defined?(:symbolize_keys)
    def symbolize_keys
      inject({}) {|hash,(k,v)| hash[k.to_sym] = v; hash }
    end
  end

  unless method_defined?(:symbolize_keys!)
    def symbolize_keys!
      replace(symbolize_keys)
    end
  end
end
