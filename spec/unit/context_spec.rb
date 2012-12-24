
require_relative '../spec_helper'

describe Papyrus::Context do
  describe '.construct_from' do
    it "returns a new Context whose vars are set to the given hash" do
      hash = { 'foo' => 'bar' }
      ctx = described_class.construct_from(hash)
      expect(ctx).to be_a_kind_of(described_class)
      expect(ctx.vars).to eq hash
    end
  end

  describe '.new' do
    it "sets @parent to the given parent node" do
      parent = Object.new
      ctx = described_class.new(parent)
      expect(ctx.parent).to eq parent
    end

    it "sets @object to the given object" do
      object = Object.new
      ctx = described_class.new(nil, object)
      expect(ctx.object).to eq object
    end

    it "sets @vars to an empty hash" do
      ctx = described_class.new
      expect(ctx.vars).to eq({})
    end
  end
end
