
require_relative '../spec_helper'

describe Papyrus::CustomBlockCommand do
  describe '#evaluate' do
    let(:cmd) {
      described_class.new("", Papyrus::NodeList.new, [])
    }

    before :each do
      stub(cmd).evaluate? { true }
      stub(cmd)._evaluates_as_command_or_variable? { true }
      cmd.ivs '@result', 'some result'
    end

    it "evaluates @args and stores the resulting array in @evaluated_args" do
      args = Papyrus::NodeList.new
      stub(args).to_a { %w(foo bar) }
      cmd.ivs '@args', args
      cmd.evaluate
      expect(cmd.evaluated_args).to eq %w(foo bar)
    end

    it "stores a copy of the original args in @orig_args" do
      args = Papyrus::NodeList.new([ Papyrus::Text.new("foo") ])
      cmd.ivs '@args', args
      cmd.evaluate
      expect(cmd.orig_args).to eq args
      expect(cmd.orig_args).not_to equal args
    end

    it "evaluates @nodes and store the resulting string in @evaluated_nodes" do
      nodes = Papyrus::NodeList.new
      stub(nodes).evaluate { %w(foo bar) }
      cmd.ivs '@nodes', nodes
      cmd.evaluate
      expect(cmd.evaluated_nodes).to eq 'foobar'
    end

    it "stores a copy of the original nodes in @orig_nodes" do
      nodes = Papyrus::NodeList.new([ Papyrus::Text.new("foo") ])
      cmd.ivs '@nodes', nodes
      cmd.evaluate
      expect(cmd.orig_nodes).to eq nodes
      expect(cmd.orig_nodes).not_to equal nodes
    end

    context 'if the block command could be evaluated' do
      it "updates the raw tokens with the result of the evaluation" do
        cmd.evaluate
        expect(cmd.ivg('@raw_tokens')).to eq Papyrus::TokenList[
          Papyrus::Token::Text.new("some result")
        ]
      end

      it "returns the result of the evaluation" do
        cmd.ivs '@result', 'some result'
        expect(cmd.evaluate).to eq 'some result'
      end
    end

    context "returns the raw sub" do
      it "if the block command shouldn't be evaluated" do
        stub(cmd).evaluate? { false }
        stub(cmd).raw_sub { '[foo]' }
        expect(cmd.evaluate).to eq '[foo]'
      end

      it "if the block command can't be evaluated" do
        stub(cmd).evaluate? { true }
        stub(cmd)._evaluates_as_command_or_variable? { false }
        stub(cmd).raw_sub { '[foo]' }
        expect(cmd.evaluate).to eq "[foo]"
      end
    end
  end

=begin
  describe '#evaluates_as_command_or_variable?' do
    it "should return true if we can evaluate the block command as a custom command" do
      cmd.stub_methods(:evaluates_as_custom_block_command? => true)
      cmd.send(:evaluates_as_command_or_variable?).should == true
    end
    it "should return true if we can evaluate the block command as a variable" do
      cmd.stub_methods(:evaluates_as_custom_block_command? => false, :evaluates_as_variable? => true)
      cmd.send(:evaluates_as_command_or_variable?).should == true
    end
  end

  describe '#evaluates_as_custom_block_command?' do
    describe "if the command is allowed and custom commands was given" do
      before do
        cmd.ivs(
          '@name' => "foo",
          '@args' => NodeList.new(%w(foo bar baz).map {|x| Text.new(x) }),
          '@evaluated_args' => %w(foo bar baz),
          '@nodes' => NodeList.new(%w(quux blargh spaz).map {|x| Text.new(x) }),
          '@evaluated_nodes' => "quuxblarghspaz"
        )
        @custom_commands = stub("class.has_block_command?" => true, :__call_block_command__ => "the final string")
        cmd.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => @custom_commands))
        @result = cmd.send(:evaluates_as_custom_block_command?)
      end
      it "should call the custom command" do
        @custom_commands.should have_received(:__call_block_command__).with(cmd)
      end
      it "should store the result of the custom command" do
        cmd.ivg("@result").should == "the final string"
      end
      it "should return true" do
        @result.should == true
      end
    end
    describe "should return false" do
      it "if the command is not allowed" do
        cmd.stub_methods(:command_allowed? => false)
      end
      it "if the command is allowed, but the block command doesn't exist" do
        custom_commands = stub("class.has_block_command?" => false)
        cmd.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => custom_commands))
      end
      it "if a ParserError is raised while the command is evaluated" do
        custom_commands = stub("class.has_block_command?" => true)
        custom_commands.stub_methods_to_raise(:__call_block_command__ => ParserError)
        cmd.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => custom_commands))
      end
      after do
        cmd.send(:evaluates_as_custom_block_command?).should == false
      end
    end
  end
=end
end

