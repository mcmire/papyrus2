
require_relative '../spec_helper'

describe Papyrus::BlockCommand do
  let(:sub_block_command_class) {
    Class.new(Papyrus::BlockCommand)
  }
  let(:fake_name) { 'foo' }
  let(:fake_args) { Papyrus::NodeList.new }
  let(:fake_raw_tokens) { [] }

  def make_block_command
    sub_block_command_class.new(fake_name, fake_args, fake_raw_tokens)
  end

  it "includes ContextItem" do
    expect(Papyrus::BlockCommand.ancestors).to include(Papyrus::ContextItem)
  end

  %w(add <<).each do |method|
    describe "##{method}" do
      it "delegates to active_block" do
        cmd = make_block_command()
        stub(block = Object.new).__send__(method)
        stub(cmd).active_block { block }
        cmd.__send__(method, :node)
        block.should have_received.__send__(method, :node)
      end
    end
  end

  describe '.new' do
    it "raises a TypeError if called directly" do
      expect { Papyrus::BlockCommand.new }.to raise_error(TypeError)
    end
  end

  describe '.active_block' do
    it "raises a NotImplementedError if called directly" do
      expect { make_block_command().active_block }.to raise_error(NotImplementedError)
    end
  end
end

