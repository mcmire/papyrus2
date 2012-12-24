
require_relative '../spec_helper'

describe Papyrus::Lexicon do
  let(:lexicon) {
    Class.new(described_class)
  }

  describe '.add_commands' do
    it "adds the given command to the global commands hash" do
      mod = Module.new
      lexicon.add_command "foo", mod
      expect(lexicon.commands[:foo]).to equal mod
    end
  end

  describe '.extend_lexicon' do
    let(:foo_class) { Class.new }
    let(:bar_class) { Class.new }
    let!(:mod) {
      foo_class = self.foo_class
      bar_class = self.bar_class
      Module.new do
        const_set(:Foo, foo_class)
        const_set(:Bar, bar_class)
      end
    }

    it "reads the classes contained in the given module and add them to the lexicon as commands" do
      lexicon.extend_lexicon(mod)
      lexicon.extensions.should include(mod)
      lexicon.commands[:foo].should equal foo_class
      lexicon.commands[:bar].should equal bar_class
    end

    it "does nothing if the lexicon has already been extended with the given class" do
      stub(lexicon).add_command
      lexicon.extend_lexicon(mod)
      lexicon.extend_lexicon(mod)
      lexicon.should have_received.add_command(:foo, anything).once
      lexicon.should have_received.add_command(:bar, anything).once
    end
  end
end

