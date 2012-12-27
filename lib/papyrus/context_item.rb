# During the parsing process, an AST gets built. As its name suggests, this is a
# tree of nodes, where each node points to its parent and eventually all the way
# back to the root Document object. Certain nodes represent variable scopes, or
# contexts, in the text document itself and therefore hold values. These nodes
# attain this behavior by including the ContextItem mixin. With it, you can
# retrieve and set these values inside the node by name. Setting a value is
# straightforward: the value just gets stored inside a hash map along with its
# key. Retrieving a value is intelligent: if the value cannot be found within
# the hash map, we go up the tree until we find another node that includes the
# ContextItem mixin, and look there. You also have the option of plugging in
# another object (an array, hash, or instance of some other class) as an
# alternate data source.
#
#
require 'forwardable'

module Papyrus
  module ContextItem
    extend Forwardable

    # **ContextItem#object=** associates an object with this node which will be
    # used when looking up values.
    #
    # * *object*: Either a hash, array, or object of some other class.
    #
    attr_writer :object

    # **ContextItem#object** gets the object set previously.
    #
    attr_reader :object

    # **ContextItem#get** searches for the given key within the source object(s)
    # within this node. If the search fails here, the search continues in an
    # ancestor node.
    #
    # The `key` here may be a simple identifier, or it may be actually be
    # multiple identifiers joined with dots (think JavaScript dot notation). The
    # idea here is that the source objects themselves can have multiple
    # dimensions to them: an index lookup in an array may return a hash, a
    # key lookup in a hash may return an array, a call on a method in an object
    # may return an array, or any of these sorts of combinations. It really only
    # makes sense when the final value you get back is a scalar, i.e., a string
    # or a number. So, here we give you a way to reach down inside of these data
    # structures to target the value you want.
    #
    # * *key*: A Symbol, or a String which may or may not contain dots. If a
    #          Symbol or a simple String, it must not start with a number.
    #
    # Returns the value that matches the given key.
    #
    # Raises an UnknownVariableError if `key` does not refer to a valid
    # identifier or the search fails.
    #
    # (FIXME: Normalize the key before looking it up)
    #
    def get(key)
      key = key.to_s
      raise UnknownVariableError if key =~ /^\d/

      first, rest = key.split(".", 2)

      value = _get_primary_part(first, key)
      return value unless rest && value

      key_parts = [first]
      value_so_far = value
      rest.split(".").each do |k|
        key_parts << k
        key_so_far = key_parts.join(".")
        value_so_far = _get_secondary_part(key_so_far, k, value_so_far)
      end
      value_so_far
    end

    # **ContextItem#set** stores the given value in the context by the given key.
    #
    # * *key*:   A Symbol, or a String which may or may not contain dots. If a
    #            Symbol or a simple String, it must not start with a number.
    # * *value*: The value you want to store. It can be anything a string,
    #            integer, hash, array, object.
    #
    def set(key, value)
      vars[key.to_s.downcase] = value
    end
    alias :[]= :set

    # **ContextItem#remove** removes the given value from the context.
    #
    # * *key*: A Symbol, or a String which may or may not contain dots. If a
    #          Symbol or a simple String, it must not start with a number.
    #
    # (TODO: Normalize the key before deleting)
    #
    def delete(key)
      vars.delete(key)
    end

    # **ContextItem#include?** (**#key?**, **#has_key?**) determines whether
    # someone has set a value on this node.
    #
    # * *key*: A Symbol, or a String which may or may not contain dots. If a
    #          Symbol or a simple String, it must not start with a number.
    #
    # Returns true or false.
    #
    def include?(key)
      vars.include?(key.to_s.downcase)
    end
    alias :key? :include?
    alias :has_key? :include?

    # **ContextItem#vars** provides easy access to all the variables stored in
    # this context.
    #
    # Returns a Hash.
    #
    def vars
      @vars ||= {}
    end

    # **ContextItem#vars=** sets the hash of values within this context,
    # converting keys to strings.
    #
    # Returns a Hash.
    #
    # (TODO: Normalize keys)
    #
    def vars=(vars)
      @vars = vars.stringify_keys
    end

    # **ContextItem#parser** provides easy access to the root Parser object.
    #
    # Returns a Parser object if this node has a parent. For the root Document
    # object, this returns nil.
    #
    # (NOTE: This is also a method in Node.)
    #
    def parser
      (parent || NullObject.new).parser
    end

    # **ContextItem#true?** determines whether a value is stored in the context
    # and has a truthy value.
    #
    # * *key*: A Symbol, or a String which may or may not contain dots. If a
    #          Symbol or a simple String, it must not start with a number.
    #
    # Returns false if the given variable is not found in the context or has a
    # falsy value, otherwise returns true.
    #
    def true?(key)
      !!get(key)
    end

    #---

    def _get_primary_part(key, whole_key)
      if vars.has_key?(key)
        vars[key]
      elsif @object.is_a?(Hash) && @object.has_key?(key)
        @object[key]
      elsif @object.is_a?(Hash) && @object.has_key?(key.to_sym)
        @object[key.to_sym]
      elsif @object.respond_to?(key.to_sym)
        @object.send(key)
      elsif @parent
        @parent.get(key)
      else
        raise UnknownVariableError
      end
    end

    def _get_secondary_part(key_so_far, key, value_so_far)
      if vars.has_key?(key_so_far)
        vars[key_so_far]
      elsif value_so_far.is_a?(Hash)
        value_so_far[key]
      elsif value_so_far.is_a?(Array) && key =~ /^\d+$/ # Array
        value_so_far[key.to_i]
      elsif value_so_far.respond_to?(key) # Just a method
        value_so_far.send(key)
      else
        raise UnknownVariableError
      end
    end
  end
end

