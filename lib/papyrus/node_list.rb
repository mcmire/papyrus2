# A NodeList is an Array-like object that serves as a container for Nodes.
# NodeLists are used to represent the entire object tree that the Parser
# produces (i.e. the Document), as well as argument lists to Commands. All Nodes
# within a NodeList point back to the NodeList as their `parent`. As it is a
# Node itself, a NodeList also has a `parent` and an #evaluate method; asking a
# NodeList to evaluate itself asks all Nodes therein to evaluate themselves.

require 'forwardable'

module Papyrus
  class NodeList < Node
    extend Forwardable

    # #### NodeList.new
    #
    # There are three ways to call this:
    #
    # 1. `NodeList.new` -- Make an empty NodeList
    #
    # 1. `NodeList.new(another_list)` -- Build a NodeList using an existing one
    #
    #    ||Arguments:||
    #    * `another_list` -- A NodeList itself; all nodes therein will be used
    #      to populate this NodeList.
    #
    # 1. `NodeList.new(nodes)` -- Build a NodeList from an existing list of
    #     Nodes
    #
    #    ||Arguments:||
    #    * `nodes` -- An Array of Nodes to populate the NodeList with.
    #
    def initialize(*args)
      @nodes = args.first || []
      @nodes = @nodes.nodes if @nodes.respond_to?(:nodes)
      @nodes.each {|node| node.parent = self }
    end

    # #### NodeList#initialize_copy
    #
    # Called on #dup or #clone.
    #
    # ||Arguments:||
    #
    # * `list` -- The original NodeList object that is being copied.
    #
    def initialize_copy(list)
      @nodes = @nodes.map { |node|
        node2 = node.clone
        node2.parent = self
        node2
      }
    end

    # ## Public methods

    # #### NodeList#nodes
    #
    # The Array of Node objects comprising the NodeList.
    #
    attr_reader :nodes

    # #### Node#orig_nodes
    #
    # Evaluating the NodeList may manipulate it if one of the Nodes therein is
    # an InsertionSub. `orig_nodes`, then, stores the version of this NodeList
    # prior to evaluation.
    #
    attr_reader :orig_nodes

    # Since NodeList wraps an Array, it is useful to work with it as though it
    # were an actual Array. We provide equivalents for the most common Array
    # operations (or at least the ones we that the author is likely to want to
    # use).
    delegate [
      :length, :size, :first, :last, :empty?, :shift, :map, :map!,
      :clear, :each, :include?, :delete,
    ] => :nodes

    # #### NodeList#add
    #
    # Adds a Node to the NodeList.
    #
    # ||Arguments:||
    #
    # * `node` -- A Node object of any type.
    #
    # Raises a TypeError if `node` is not a Node.
    #
    # Returns this NodeList so you can chain calls.
    #
    # *Aliased as:* NodeList#<<
    #
    def add(node)
      return unless node
      unless Node === node
        raise TypeError, "NodeList#add: Expected a Node, got a #{node.class} = #{node.inspect}"
      end
      @nodes << node
      node.parent = self
      self
    end
      # For some reason we cannot use `alias_method` here and I cannot for the
      # life of me remember why...
    def <<(node); add(node); end

    # #### NodeList#evaluate
    #
    # Converts the NodeList to text form by asking all of the Nodes inside it to
    # evaluate themselves.
    #
    # Usually returns an Array of Strings. In the case of BodyNodeList#evaluate,
    # however, it returns an Array of BodyStrings. This is in order to
    # facilitate post-processing of the body after it has been integrated
    # into the root Document (as by this point BodyNodeList is no more).
    #
    def evaluate
      arr = []
      laststr = nil
      # Evaluate all the Nodes, turning each one into a String, SeparateString,
      # or BodyString.
      strings = _evaluated_nodes

      # Now process the resulting Array. All strings are concatenated together
      # except for BodyStrings and SeparateStrings; we need to preserve and
      # isolate these so that processing them later is possible. (BodyStrings
      # are used when evaluating a Document to represent `[body]` content,
      # SeparateStrings are used when evaluating a Command's argument list to
      # represent the individual arguments.)
      strings.each do |str|
        if arr.empty? || SeparateString === str || SeparateString === laststr ||
           BodyString === str || BodyString === laststr
          # Keep BodyStrings separate.
          if BodyString === str
            arr << str
          # Keep SeparateStrings separate.
          elsif SeparateString === str
            arr << String.new(str)
          # A BodyNodeList stores a list of BodyStrings, not Strings.
          elsif BodyNodeList === self
            arr << BodyString.new(str)
          else
            arr << str
          end
        # Combine Strings that appear in the NodeList successively.
        else
          arr.last << str
        end
        laststr = str
      end
      arr
    end

    # #### NodeList#to_a
    #
    # Evaluates all the Nodes in the NodeList. This is a lower-level method than
    # #evaluate, which will do some special logic to combine strings.
    #
    # Returns an Array of Strings.
    #
    def to_a
      _evaluated_nodes
    end

    # #### NodeList#expand_current
    #
    # Replaces a Sub inside of this NodeList with a set of different nodes,
    # wrapped in their own NodeList. The Sub via the InsertionSub module will
    # call this method as the NodeList is being iterated over.
    #
    # Note that this method destructively modifies the given Nodes by realigning
    # their parent pointers. This is okay, since we are assuming that the Nodes
    # came from a temporary Document object.
    #
    # ||Arguments:||
    #
    # * `nodes` -- An Array of Nodes, or a NodeList.
    # * `klass` -- The NodeList class to use to wrap the `nodes` in. Usually
    #   this is NodeList, but `[body]` specially uses a BodyNodeList.
    #
    def expand_current(nodes, klass)
      nodes.each {|node| node.old_parent = node.parent }
      list = klass.new(nodes)
      list.parent = self
      @nodes[@pos] = list
    end

    # #### NodeList#flatten
    #
    # Collapses the NodeList, converting it from a multi-dimensional tree of
    # Nodes to a one-dimensional list.
    #
    # Based off Rubinius code.
    #
    # Returns a new NodeList.
    #
    def flatten
      out = []
      _recursively_flatten_to!(self, out)
      list = NodeList.new(out)
      list.parent = self.parent
      list
    end

    # #### NodeList#==
    #
    # Compares this NodeList with another for equality. This method exists
    # mainly for testing purposes.
    #
    # ||Arguments:||
    #
    # * `other` -- Another NodeList.
    #
    # Returns true if `other` is a NodeList and has the same nodes as this
    # NodeList.
    #
    def ==(other)
      other.is_a?(self.class) &&
      @nodes == other.nodes
    end

    # ## Internal methods

    # #### NodeList#pretty_print_instance_variables
    #
    # Controls which data to include in the PrettyPrint (pp) version of the
    # object. Certain objects are rather verbose when pretty printed, so exclude
    # these from the output.
    #
    def pretty_print_instance_variables
      %w(@nodes)
    end

    # ## Private methods

    # #### NodeList#_evaluated_nodes
    #
    # Walks the tree of Nodes in the NodeList and recursively evaluates all of
    # the Nodes inside (i.e., converts them all to Strings). A special case is
    # made to prevent an infinite recursion when evaluating a Node which
    # eventually includes itself in the result of its evaluation.
    #
    # Returns an Array of {String | SeparateString}.
    #
    def _evaluated_nodes
      # Back up the current list of Nodes in case we need it later, as some
      # Nodes may get manipulated.
      @orig_nodes ||= @nodes.clone
      arr = []
      # Keep track of which Node the iterator is on. This is used in
      # #expand_current above to modify the NodeList during iteration.
      @pos = 0
      i = 0
      while @pos < @nodes.size
        node = @nodes[@pos]
        result = nil
        #
        # > **2015 JENNIFER:** "I'm young!"
        # >
        # > **1985 JENNIFER (simultaneously):** "I'm old!"
        # >
        # > -- *Back to the Future, Part II*
        #
        # Some Nodes actually evaluate to themselves. An example would be a
        # variable `[great]` that has the value of `This is a [great] day`.
        # If unchecked, evaluating these kinds of Nodes would naturally lead to
        # a never-ending loop (`[great]` would resolve to `This is a [great]
        # day`, which would resolve to `This is a This is a [great] day day`,
        # which would resolve to...). We have to stop somewhere, and so we
        # have made a conscious choice in Papyrus to only resolve the first
        # level. Hence, in our example, `This is a [great] day` would be the
        # final string -- once Papyrus sees the inner `[great]`, it notices that
        # it's the same as the outer instance, and decides not to evaluate
        # further.
        #
        # This is where we do that. A Node that is an exact copy of a Node in a
        # higher level in the tree is called the "insertion doppelganger" of
        # that Node. When this kind of Node is evaluated, the result is the raw
        # representation of that node -- in other words, how it originally
        # looked in the source document.
        #
        if (node.respond_to?(:insertion_doppelganger) &&
           node == node.insertion_doppelganger)
          result = node.insertion_doppelganger.raw_sub
        else
          begin
            result = node.evaluate
          # If an InsertionSub which is not detected to be an insertion
          # doppelganger of an ancestor node is evaluated, and it replaces
          # itself with a NodeList, then we need to evaluate that NodeList
          # instead of continuing on to the next Node in this NodeList. The
          # RedoEvaluation, albeit crudely, accomplishes this.
          rescue RedoEvaluation
            i += 1
            raise "Infinite loop" if i == 50
            next
          end
        end

        if result.nil?
          raise "A node evaluates to nil!\n#{node.pretty_inspect}"
        end

        i = 0
        # NodeLists will evaluate to Arrays, everything else will evaluate to
        # Strings.
        if Array === result
          arr += result
        else
          arr << result
        end
        @pos += 1
      end
      arr
    end

    # #### NodeList#_recursively_flatten_to!
    #
    # The recursive counterpart to #flatten. It walks the given array, dumping
    # all of the non-array items into a flat array.
    #
    # ||Arguments:||
    #
    # * `array` -- A NodeList or Array which will be walked.
    # * `out`   -- A final Array into which all of the Nodes will be placed.
    #
    # Returns nothing.
    #
    def _recursively_flatten_to!(array, out)
      array.each do |o|
        if NodeList === o
          _recursively_flatten_to!(o.nodes, out)
        elsif o.respond_to?(:to_ary)
          ary = Array === o ? o : o.to_ary
          _recursively_flatten_to!(ary, out)
        else
          out << o
        end
      end
    end
  end
end

