
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
