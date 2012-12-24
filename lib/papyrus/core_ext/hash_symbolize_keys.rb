
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
