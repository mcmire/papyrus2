
require_relative '../spec_helper'

describe Papyrus::Document do
  let(:doc) { described_class.new(nil) }

  it "should be a ContextItem" do
    described_class.ancestors.should include(Papyrus::ContextItem)
  end

  describe '.new' do
    it "should set @parser to the given value" do
      doc = described_class.new(:parser)
      expect(doc.parser).to eq :parser
    end

    it "should initialize the @nodes array using the given NodeList" do
      doc = described_class.new(:parser, Papyrus::NodeList.new([ Papyrus::Text.new("foo") ]))
      expect(doc.nodes).to eq [ Papyrus::Text.new("foo") ]
    end
  end

  describe '#document' do
    it "should just return the Document object" do
      expect(doc.document).to equal doc
    end
  end

  describe '#template' do
    it "delegates to the parser" do
      parser = stub!.template { :template }
      stub(doc).parser { parser }
      expect(doc.template).to eq :template
    end
  end

  describe '#options' do
    it "delegates to the template" do
      stub(template = Object.new) do
        options { :options }
      end
      stub(doc).template { template }
      expect(doc.options).to eq :options
    end
  end

  describe '#vars' do
    it "delegates to the template" do
      stub(template = Object.new) do
        vars { :vars }
      end
      stub(doc).template { template }
      expect(doc.vars).to eq :vars
    end
  end
end

