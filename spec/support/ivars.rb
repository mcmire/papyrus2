
class Object
  alias_method :ivg, :instance_variable_get
  public :ivg
  def ivs(name_or_hash, value=nil)
    if name_or_hash.is_a?(Hash)
      name_or_hash.each {|name, value| instance_variable_set(name, value) }
    else
      instance_variable_set(name_or_hash, value)
    end
  end
end

#class Module
  #alias_method :cvg, :class_variable_get
  #public :cvg
  #def cvs(name_or_hash, value=nil)
    #if name_or_hash.is_a?(Hash)
      #name_or_hash.each {|name, value| class_variable_set(name, value) }
    #else
      #class_variable_set(name_or_hash, value)
    #end
  #end
#end
