
require_relative '../spec_helper'

describe Papyrus::InsertionSub do
  let(:wrapper_class) {
    Class.new do
      include Papyrus::InsertionSub
    end
  }

  before do
    @inserter = wrapper_class.new
  end

  describe '#parse_and_insert_into_parent' do
    def setup
      @parent = Object.new
      stub(@parent).expand_current { nil }
      @new_doc = Object.new
      @template = stub!.clone_with { stub!.analyze { @new_doc } }
      stub(@inserter).template { @template }
      stub(@inserter).parent { @parent }
    end

    it "should return an empty string if the given content is blank" do
      setup
      str = nil
      expect { str = @inserter.parse_and_insert_into_parent("") }.
        to_not raise_error(Papyrus::RedoEvaluation)
      expect(str).to eq ""
      expect(@template).not_to have_received.clone_with
      expect(@parent).not_to have_received.expand_current
    end

    it "should run the content through a new Parser instance, insert the nodes into the current document, and raise RedoEvaluation at the end" do
      setup
      nodes = [ Papyrus::Sub.new("foo", Papyrus::NodeList.new, Papyrus::TokenList.new) ]
      stub(@new_doc).nodes { nodes }
      expect { @inserter.parse_and_insert_into_parent("something") }.
        to raise_error(Papyrus::RedoEvaluation)
      stub(@parent).to have_received.expand_current(nodes, Papyrus::NodeList)
    end

    it "should insert a BodyNodeList into the document if this insertion sub is a [body] variable" do
      @inserter = Papyrus::Variable.new("body", [])
      setup
      nodes = [ Papyrus::Sub.new("foo", Papyrus::NodeList.new, []) ]
      stub(@new_doc).nodes { nodes }
      begin
        @inserter.parse_and_insert_into_parent("something")
      rescue Papyrus::RedoEvaluation
      end
      expect(@parent).to have_received.expand_current(nodes, Papyrus::BodyNodeList)
    end

    it "should parse the given content and return its evaluation immediately if it doesn't have any subs in it" do
      setup
      stub(@new_doc).nodes { [ Papyrus::Text.new("foo") ] }
      stub(@new_doc).evaluate { ['the result'] }
      result = nil
      expect {
        result = @inserter.parse_and_insert_into_parent("something")
      }.to_not raise_error(Papyrus::RedoEvaluation)
      expect(result).to eq "the result"
      expect(@parent).not_to have_received.expand_current
    end
  end
end

