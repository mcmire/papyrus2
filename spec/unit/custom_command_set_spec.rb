
require_relative '../spec_helper'

describe Papyrus::CustomCommandSet do
  let(:klass) { Class.new(described_class) }

  describe '.command_properties' do
    it "assigns @command_properties a new hash if it's not defined yet" do
      klass.command_properties
      expect(klass.ivg('@command_properties')).to eq({})
    end

    it "sets the default value of the hash to a hash" do
      klass.command_properties['foo']['bar'] = 'baz'
      expect(klass.ivg('@command_properties')['foo']['bar']).to eq 'baz'
    end

    it "returns the value of @command_properties if it's already defined" do
      klass.ivs('@command_properties', { :foo => 'bar' })
      expect(klass.command_properties).to eq({:foo => 'bar'})
    end
  end

  describe '.aliases' do
    it "assigns @aliases a new hash if it's not defined yet" do
      klass.aliases
      expect(klass.ivg('@aliases')).to eq({})
    end

    it "returns the value of @aliases if it's already defined" do
      klass.ivs('@aliases', { :foo => 'bar' })
      expect(klass.aliases).to eq({:foo => 'bar'})
    end
  end

  describe '.alias_command' do
    it "stores the name of the real command under the name of the alias" do
      klass.alias_command 'jimmy', 'fallon'
      klass.aliases[:fallon].should == :jimmy
    end

    it "ensures the alias is stored lowercase" do
      klass.alias_command 'jiMmY', 'fallon'
      klass.aliases[:fallon].should == :jimmy
    end

    it "ensures the alias is stored as a symbol" do
      klass.alias_command :jimmy, 'fallon'
      klass.aliases[:fallon].should == :jimmy
    end

    it "ensures the real command is stored lowercase" do
      klass.alias_command 'jimmy', 'fAllOn'
      klass.aliases[:fallon].should == :jimmy
    end

    it "ensures the real command is stored as a symbol" do
      klass.alias_command 'jimmy', :fallon
      klass.aliases[:fallon].should == :jimmy
    end
  end

  describe '.dont_pre_evaluate_args' do
    it "sets :pre_evaluate_args to false for the given commands" do
      klass.dont_pre_evaluate_args :jimmy, :fallon
      expect(klass.command_properties[:jimmy][:pre_evaluate_args]).to be false
      expect(klass.command_properties[:fallon][:pre_evaluate_args]).to be false
    end

    it "normalizes the given command names" do
      klass.dont_pre_evaluate_args 'apple', 'bAker', :chaRliE
      expect(klass.command_properties[:apple][:pre_evaluate_args]).to be false
      expect(klass.command_properties[:baker][:pre_evaluate_args]).to be false
      expect(klass.command_properties[:charlie][:pre_evaluate_args]).to be false
    end
  end

  describe '.has_inline_command?' do
    it "returns true if the command set has an InlineCommands method which has an instance method for this command" do
      klass.const_set(:InlineCommands, Module.new do
        def fallon; end
      end)
      expect(klass.has_inline_command?('fallon')).to be true
      expect(klass.has_inline_command?(:fallon)).to be true
      expect(klass.has_inline_command?('fAllOn')).to be true
      expect(klass.has_inline_command?(:fAllOn)).to be true
    end

    it "returns true if the command set has an InlineCommands method which has an alias for an instance method for this command" do
      klass.const_set(:InlineCommands, Module.new do
        def fallon; end
      end)
      klass.alias_command :fallon, :jimmy
      expect(klass.has_inline_command?('jimmy')).to be true
      expect(klass.has_inline_command?(:jimmy)).to be true
      expect(klass.has_inline_command?('jiMmY')).to be true
      expect(klass.has_inline_command?(:jimmy)).to be true
    end

    it "returns false if there is no InlineCommands module defined" do
      expect(klass.has_inline_command?('whatever')).to be false
    end
  end

  describe '.has_block_command?' do
    it "returns true if the command set has an BlockCommands method which has an instance method for this command" do
      klass.const_set(:BlockCommands, Module.new do
        def fallon; end
      end)
      expect(klass.has_block_command?('fallon')).to be true
      expect(klass.has_block_command?(:fallon)).to be true
      expect(klass.has_block_command?('fAllOn')).to be true
      expect(klass.has_block_command?(:fAllOn)).to be true
    end

    it "returns true if the command set has an BlockCommands method which has an alias for an instance method for this command" do
      klass.const_set(:BlockCommands, Module.new do
        def fallon; end
      end)
      klass.alias_command :fallon, :jimmy
      expect(klass.has_block_command?('jimmy')).to be true
      expect(klass.has_block_command?(:jimmy)).to be true
      expect(klass.has_block_command?('jiMmY')).to be true
      expect(klass.has_block_command?(:jimmy)).to be true
    end

    it "returns false if there is no BlockCommands module defined" do
      expect(klass.has_block_command?('whatever')).to be false
    end
  end
end

describe Papyrus::CustomCommandSet do
  describe '.new' do
    it "sets @template to the given template" do
      set = described_class.new(:template, [])
      expect(set.template).to eq :template
    end

    it "sets @args to the given args" do
      set = described_class.new(nil, %w(foo bar))
      expect(set.args).to eq %w(foo bar)
    end

    it "extends the current object with the custom commands defined" do
      subclass = Class.new(described_class) do
        def ok?; end
      end
      subclass.const_set(:InlineCommands, Module.new do
        def foo; end
      end)
      subclass.const_set(:BlockCommands, Module.new do
        def bar; end
      end)
      subset = subclass.new(:template)
      expect(subset).to respond_to(:foo)
      expect(subset).to respond_to(:bar)
      expect(subset).to respond_to(:ok?)
    end
  end

  %w(dup clone).each do |method|
    describe "##{method} (via #initialize_copy)" do
      it "makes a shallow copy of the args" do
        set = described_class.new(:template, {:foo => "bar"})
        set2 = set.__send__(method)
        set2.args[:baz] = "quux"
        expect(set.args[:baz]).to be_nil
      end

      it "extends the current object with the custom commands defined" do
        subclass = Class.new(described_class) do
          def ok?; end
        end
        subclass.const_set(:InlineCommands, Module.new do
          def foo; end
        end)
        subclass.const_set(:BlockCommands, Module.new do
          def bar; end
        end)
        subset = subclass.new(:template)
        subset2 = subset.__send__(method)
        expect(subset2).to respond_to(:foo)
        expect(subset2).to respond_to(:bar)
        expect(subset2).to respond_to(:ok?)
      end
    end
  end

  describe '#__call_inline_command__' do
    let(:subclass) { Class.new(described_class) }
    let(:set) { subclass.new(nil, []) }

    it "should call the given inline command with the arrayified arguments, if the command is defined" do
      stub(subclass).has_inline_command? { true }
      stub(set).foo { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        evaluated_args { %w(foo bar) }
      end
      value = set.send(:__call_inline_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.foo(%w(foo bar))
    end

    it "should call the given inline command with the original argument NodeList, if the command was defined with :pre_evaluate_args => false" do
      subclass.dont_pre_evaluate_args :foo
      stub(subclass).has_inline_command? { true }
      stub(set).foo { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        orig_args { %w(foo bar) }
      end
      value = set.send(:__call_inline_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.foo(%w(foo bar))
    end

    it 'should call #inline_command_missing if the inline command is not defined' do
      stub(subclass).has_inline_command? { false }
      stub(set).inline_command_missing { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        evaluated_args { %w(foo bar) }
      end
      value = set.send(:__call_inline_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.inline_command_missing(:foo, %w(foo bar))
    end
  end

  describe '#__call_block_command__' do
    let(:subclass) { Class.new(described_class) }
    let(:set) { subclass.new(nil, []) }

    it "should call the given block command with the arrayified arguments, if the command is defined" do
      stub(subclass).has_block_command? { true }
      stub(set).foo { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        evaluated_args { %w(foo bar) }
        evaluated_nodes { :inner }
      end
      value = set.send(:__call_block_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.foo(%w(foo bar), :inner)
    end

    it "should call the given block command with the original argument NodeList, if the command was defined with :pre_evaluate_args => false" do
      subclass.dont_pre_evaluate_args :foo
      stub(subclass).has_block_command? { true }
      stub(set).foo { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        orig_args { %w(foo bar) }
        evaluated_nodes { :inner }
      end
      value = set.send(:__call_block_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.foo(%w(foo bar), :inner)
    end

    it 'should call #block_command_missing if the block command is not defined' do
      stub(subclass).has_block_command? { false }
      stub(set).block_command_missing { 'return value' }
      stub(sub = Object.new) do
        name { 'foo' }
        evaluated_args { %w(foo bar) }
        evaluated_nodes { :inner }
      end
      value = set.send(:__call_block_command__, sub)
      expect(value).to eq 'return value'
      expect(set).to have_received.block_command_missing(:foo, %w(foo bar), :inner)
    end
  end

  describe '#inline_command_missing' do
    it "should raise an UnknownSubError by default" do
      expect { described_class.new(nil, []).send(:inline_command_missing, "", []) }.
        to raise_error(Papyrus::UnknownSubError)
    end
  end

  describe '#block_command_missing' do
    it "should raise an UnknownSubError by default" do
      expect { described_class.new(nil, []).send(:block_command_missing, "", [], []) }.
        to raise_error(Papyrus::UnknownSubError)
    end
  end
end

