
require_relative '../spec_helper'

describe Papyrus::NodeList do
  let(:list) { described_class.new }

  describe '.new' do
    it "sets @nodes to an empty list by default" do
      expect(list.nodes).to eq []
    end

    it "sets @nodes to the given value" do
      list = described_class.new([ Papyrus::Text.new("foo"), Papyrus::Text.new("bar") ])
      expect(list.nodes).to eq [ Papyrus::Text.new("foo"), Papyrus::Text.new("bar") ]
    end

    it "if a described_class is given, sets @nodes to its nodes (not the described_class itself)" do
      inner_list = described_class.new([ Papyrus::Text.new("foo") ])
      list = described_class.new(inner_list)
      expect(list.nodes).to eq [ Papyrus::Text.new("foo") ]
    end

    it "ensures that all the top-level nodes have this described_class as its parent" do
      text1 = Papyrus::Text.new("foo"); text1.parent = :joe
      text2 = Papyrus::Text.new("bar"); text2.parent = :mark
      list = described_class.new([ text1, text2 ])
      expect(list.nodes[0].parent).to equal list
      expect(list.nodes[1].parent).to equal list
    end
  end

  describe '#initialize_copy' do
    it "makes a copy of the @nodes array, making sure to also make copies of any inner described_classs" do
      foo, sublist, quux = nodes = [
        Papyrus::Text.new("foo"),
        described_class.new([ Papyrus::Text.new("bar"), Papyrus::Text.new("baz") ]),
        Papyrus::Text.new("quux")
      ]
      list = described_class.new(nodes)
      list2 = list.clone
      foo2, sublist2, quux2 = list2.nodes

      expect(foo2).not_to equal foo
      expect(quux2).not_to equal quux
      expect(sublist2).not_to equal sublist
      sublist2 << Papyrus::Text.new("zing")
      expect(sublist).not_to include Papyrus::Text.new("zing")
    end
  end

  describe '#length' do
    it "delegates to nodes" do
      stub(nodes = Object.new).length
      stub(list).nodes { nodes }
      list.length
      expect(nodes).to have_received.length
    end
  end

  describe '#size' do
    it "delegates to nodes" do
      stub(nodes = Object.new).size
      stub(list).nodes { nodes }
      list.size
      expect(nodes).to have_received.size
    end
  end

  describe '#first' do
    it "delegates to nodes" do
      stub(nodes = Object.new).first
      stub(list).nodes { nodes }
      list.first
      expect(nodes).to have_received.first
    end
  end

  describe '#last' do
    it "delegates to nodes" do
      stub(nodes = Object.new).last
      stub(list).nodes { nodes }
      list.last
      expect(nodes).to have_received.last
    end
  end

  describe '#empty?' do
    it "delegates to nodes" do
      stub(nodes = Object.new).empty?
      stub(list).nodes { nodes }
      list.empty?
      expect(nodes).to have_received.empty?
    end
  end

  describe '#shift' do
    it "delegates to nodes" do
      stub(nodes = Object.new).shift
      stub(list).nodes { nodes }
      list.shift
      expect(nodes).to have_received.shift
    end
  end

  describe '#map' do
    it "delegates to nodes" do
      stub(nodes = Object.new).map
      stub(list).nodes { nodes }
      list.map
      expect(nodes).to have_received.map
    end
  end

  describe '#map!' do
    it "delegates to nodes" do
      stub(nodes = Object.new).map!
      stub(list).nodes { nodes }
      list.map!
      expect(nodes).to have_received.map!
    end
  end

  describe '#clear' do
    it "delegates to nodes" do
      stub(nodes = Object.new).clear
      stub(list).nodes { nodes }
      list.clear
      expect(nodes).to have_received.clear
    end
  end

  describe '#each' do
    it "delegates to nodes" do
      stub(nodes = Object.new).each
      stub(list).nodes { nodes }
      list.each
      expect(nodes).to have_received.each
    end
  end

  describe '#include?' do
    it "delegates to nodes" do
      stub(nodes = Object.new).include?
      stub(list).nodes { nodes }
      list.include?
      expect(nodes).to have_received.include?
    end
  end

  describe '#delete' do
    it "delegates to nodes" do
      stub(nodes = Object.new).delete
      stub(list).nodes { nodes }
      list.delete
      expect(nodes).to have_received.delete
    end
  end

  %w(add <<).each do |method|
    describe "##{method}" do
      it "does nothing if given nil" do
        list.__send__(method, nil)
        expect(list.nodes).to be_empty
      end

      it "raises a TypeError if given something other than a Node" do
        expect { described_class.new.__send__(method, "not a command") }.
          to raise_error(TypeError)
      end

      it "adds the given Node to @nodes" do
        node = Papyrus::Node.new
        list.__send__(method, node)
        expect(list.nodes).to include node
      end

      it "sets the parent of the given node to the described_class" do
        cmd = Papyrus::Command.new("", described_class.new, nil)
        list.__send__(method, cmd)
        expect(cmd.parent).to equal list
      end
    end
  end

  describe '#evaluate' do
    describe "within described_class" do
      it "takes #evaluated_nodes and joins consecutive strings into a string" do
        stub(list)._evaluated_nodes { %w(foo bar baz) }
        expect(list.evaluate).to eq ["foobarbaz"]
      end

      it "adds BodyStrings straight to the returned array as separate items" do
        stub(list)._evaluated_nodes {
          ["foo", "bar", Papyrus::BodyString.new("baz"), "zing", "zang"]
        }
        expect(list.evaluate).to eq ["foobar", Papyrus::BodyString.new("baz"), "zingzang"]
      end

      it "adds SeparateStrings to the returned array as separate items, but casting them to strings first" do
        stub(list)._evaluated_nodes {
          ["foo", "bar", Papyrus::SeparateString.new("baz"), "zing", "zang"]
        }
        expect(list.evaluate).to eq ["foobar", "baz", "zingzang"]
      end
    end

    describe "within Papyrus::BodyNodeList" do
      it "takes strings that aren't already marked as BodyStrings or SeparateStrings and add them as BodyStrings" do
        list = Papyrus::BodyNodeList.new
        stub(list)._evaluated_nodes { ["foo", "bar", "baz"] }
        expect(list.evaluate).to eq [ Papyrus::BodyString.new("foobarbaz") ]
      end

      it "still adds strings that are marked as BodyStrings or SeparateStrings separately, though" do
        list = Papyrus::BodyNodeList.new
        stub(list)._evaluated_nodes {
          [ "foo", "bar", Papyrus::BodyString.new("baz"), "zingaling", "frimfrou",
            Papyrus::SeparateString.new("tenacious d") ]
        }
        expect(list.evaluate).to eq [
          Papyrus::BodyString.new("foobar"),
          Papyrus::BodyString.new("baz"),
          Papyrus::BodyString.new("zingalingfrimfrou"),
          "tenacious d"
        ]
      end
    end
  end

  describe '#to_a' do
    it "simply calls #evaluated_nodes" do
      stub(list)._evaluated_nodes { nil }
      list.to_a
      list.should have_received._evaluated_nodes
    end
  end

  describe '#expand_current' do
    def text_nodes(args)
      args.map {|x| Papyrus::Text.new(x) }
    end

    before do
      list.ivs '@pos', 1
      list.ivs '@nodes', text_nodes(%w(foo bar baz))
    end

    it "replaces the node at the current position with the given nodes" do
      klass = Class.new(Papyrus::Node) do
        attr_reader :nodes
        def initialize(nodes)
          @nodes = nodes
        end
      end
      nodes = text_nodes(%w(zing zang))
      list.expand_current(nodes, klass)
      expect(list.nodes[0]).to eq Papyrus::Text.new('foo')
      expect(list.nodes[1]).to be_a(klass)
      expect(list.nodes[1].nodes).to equal nodes
      expect(list.nodes[2]).to eq Papyrus::Text.new('baz')
    end

    it "makes the new node list a child of this node list" do
      nodes = text_nodes(%w(zing zang))
      list.expand_current(nodes, described_class)
      expect(list.nodes[1].parent).to eq list
    end

    it "wraps the given nodes in the given node list class" do
      nodes = text_nodes(%w(zing zang))
      list.expand_current(nodes, Papyrus::BodyNodeList)
      expect(list.nodes[1]).to be_a Papyrus::BodyNodeList
    end

    it "stores the current parent of each node before changing it" do
      text = Papyrus::Text.new("foo")
      text.parent = :parent
      expect(text.old_parent).to eq nil
      list.expand_current([text], described_class)
      expect(text.old_parent).to equal :parent
    end
  end

  describe '#flatten' do
    it "collapses the described_class so that it does not contain any inner described_classs" do
      list = described_class.new([
        Papyrus::Text.new("foo"),
        described_class.new([
          Papyrus::Text.new("bar"),
          described_class.new([
            Papyrus::Text.new("baz")
          ]),
          Papyrus::Text.new("quux")
        ]),
        Papyrus::Text.new("zing")
      ])
      expect(list.flatten).to eq described_class.new(
        %w(foo bar baz quux zing).map {|str| Papyrus::Text.new(str) }
      )
    end

    it "assigns the new described_class the same parent as the original described_class" do
      list = described_class.new
      list2 = list.flatten
      expect(list2.parent).to eq list.parent
    end
  end

  describe '#==' do
    it "returns true if the given object is a described_class and has the same nodes" do
      list = described_class.new
      list.ivs "@nodes", [
        Papyrus::Text.new("one"),
        Papyrus::Text.new("two"),
        Papyrus::Text.new("three")
      ]
      list2 = described_class.new
      list2.ivs "@nodes", [
        Papyrus::Text.new("one"),
        Papyrus::Text.new("two"),
        Papyrus::Text.new("three")
      ]
      expect(list).to eq list2
    end

    it "returns false if the given object is not a described_class" do
      list = described_class.new
      other = String.new
      expect(list).not_to eq other
    end

    it "returns false if the given object is a described_class but does not have the same nodes" do
      list = described_class.new
      list.ivs "@nodes", [
        Papyrus::Text.new("one"),
        Papyrus::Text.new("two"),
        Papyrus::Text.new("three")
      ]
      list2 = described_class.new
      list2.ivs "@nodes", [
        Papyrus::Text.new("two"),
        Papyrus::Sub.new("three", described_class.new, Papyrus::TokenList.new)
      ]
      expect(list).not_to eq list2
    end
  end

  #---

=begin
  describe '#evaluated_nodes' do
    it "should evaluate each node in @nodes and return an array of strings" do
      list = described_class.new([ Papyrus::Text.new("one"), Papyrus::Text.new("two"), Papyrus::Text.new("three") ])
      list.send(:evaluated_nodes).should == %w(one two three)
    end
    it "should merge the array to which described_class evaluates with the returned array, instead of appending it" do
      sub = Sub.new("foo", described_class.new, [])
      sub.stub_methods(:evaluate => SeparateString.new("whatever"))
      list2 = described_class.new([ Papyrus::Text.new("zing"), sub, Papyrus::Text.new("zang") ])
      list = described_class.new([ Papyrus::Text.new("one"), list2, Papyrus::Text.new("three") ])
      list.send(:evaluated_nodes).should == %w(one zing whatever zang three)
    end
    it "should back up @nodes to @orig_nodes before evaluating" do
      @list.ivs "@nodes", [ Papyrus::Text.new("foo") ]
      @list.send(:evaluated_nodes)
      @list.ivg("@orig_nodes").should == [ Papyrus::Text.new("foo") ]
    end
    it "should raise an infinite loop message if RedoEvaluation is raised but @pos is never changed" do
      node = Papyrus::Text.new("foo")
      node.stub_methods_to_raise(:evaluate => RedoEvaluation)
      @list.ivs "@nodes", [ node ]
      lambda { @list.send(:evaluated_nodes) }.should raise_error(RuntimeError, "Infinite loop")
    end
    it "should not evaluate a sub if doing so would create an infinite loop" do
      sub = Sub.new("foo", described_class.new, TokenList.new)
      sub2 = sub.dup
      sub2.stub_methods(:raw_sub => "[stuff]")
      sub.stub_methods(:insertion_doppelganger => sub2)
      @list.ivs "@nodes", [ sub ]
      @list.send(:evaluated_nodes).should == ["[stuff]"]
    end
    it "should crash if any node evaluates to nil" do
      node = stub(:evaluate => nil)
      @list.ivs "@nodes", [ node ]
      lambda { @list.send(:evaluated_nodes) }.should raise_error
    end
  end
=end
end
