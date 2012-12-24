
require_relative '../spec_helper'

describe Papyrus::InlineSub do
  let(:sub) { described_class.new("", Papyrus::NodeList.new, []) }

  describe '#evaluate' do
    before :each do
      stub(sub)._evaluates_as_inline_command_or_variable? { true }
      sub.ivs '@result', 'some result'
    end

    it "evaluates @args and stores the resulting array in @evaluated_args" do
      args = Papyrus::NodeList.new
      stub(args).to_a { %w(foo bar) }
      sub.ivs "@args", args
      sub.evaluate
      expect(sub.evaluated_args).to eq %w(foo bar)
    end

    it "makes a copy of @args before it's evaluated" do
      args = Papyrus::NodeList.new([ Papyrus::Text.new("foo") ])
      sub.ivs "@args", args
      sub.evaluate
      expect(sub.orig_args).to eq args
    end

    describe "if the sub could be evaluated" do
      it "updates the raw tokens with the result of the evaluation" do
        sub.evaluate
        expect(sub.raw_tokens).to eq Papyrus::TokenList[
          Papyrus::Token::Text.new("some result")
        ]
      end

      it "returns the result of the evaluation" do
        sub.ivs "@result", "some result"
        expect(sub.evaluate).to eq "some result"
      end
    end

    describe "returns the raw sub" do
      it "if the inline sub shouldn't be evaluated" do
        stub(sub) do
          evaluate? { false }
          raw_sub { '[foo]' }
        end
        expect(sub.evaluate).to eq '[foo]'
      end

      it "if the inline sub can't be evaluated" do
        stub(sub) do
          evaluate? { false }
          _evaluates_as_inline_command_or_variable? { false }
          raw_sub { '[foo]' }
        end
        expect(sub.evaluate).to eq '[foo]'
      end
    end
  end

  #---

=begin
  describe '#evaluates_as_inline_command_or_variable?' do
    before :each do
      sub.stub_methods(
        :evaluates_as_builtin_command? => false,
        :evaluates_as_custom_inline_command? => false,
        :evaluates_as_variable? => false
      )
    end

    it "should return true if we can evaluate the sub as a built-in command" do
      sub.stub_methods(:evaluates_as_builtin_command? => true)
      sub.send(:evaluates_as_inline_command_or_variable?).should == true
    end

    it "should return true if we can evaluate the sub as a custom command" do
      sub.stub_methods(:evaluates_as_custom_inline_command? => true)
      sub.send(:evaluates_as_inline_command_or_variable?).should == true
    end

    it "should return true if we can evaluate the sub as a variable" do
      sub.stub_methods(:evaluates_as_variable? => true)
      sub.send(:evaluates_as_inline_command_or_variable?).should == true
    end
  end

  describe '#evaluates_as_builtin_command?' do
    it "should return true if the command is allowed and the command is in the lexicon" do
      sub.stub_methods(:command_allowed? => true)
      klass = Class.new(Sub) { def evaluate; ""; end }
      Papyrus::Lexicon.stub_methods(:commands => { "foo" => klass })
      sub.ivs "@name", "foo"
      sub.ivs "@orig_args", Papyrus::NodeList.new
      sub.send(:evaluates_as_builtin_command?).should == true
    end

    it "should return false if the command is not allowed" do
      sub.stub_methods(:command_allowed? => false)
      sub.send(:evaluates_as_builtin_command?).should == false
    end

    it "should return false if the command is allowed, but the command is not in the lexicon" do
      sub.stub_methods(:command_allowed? => true)
      Papyrus::Lexicon.stub_methods(:commands => {})
      sub.send(:evaluates_as_builtin_command?).should == false
    end

    it "should return nil if a ParserError is raised while the command is evaluated" do
      sub.stub_methods(:command_allowed? => true)
      klass = Class.new(Sub) { def evaluate; raise ParserError; end }
      Papyrus::Lexicon.stub_methods(:commands => { "foo" => klass })
      sub.ivs "@name", "foo"
      sub.ivs "@orig_args", Papyrus::NodeList.new
      sub.send(:evaluates_as_builtin_command?).should == false
    end
    # how do we add tests for setting parent and wrapper?
  end

  describe '#evaluates_as_custom_inline_command?' do
    describe "if the command is allowed and a custom command set was given" do
      before do
        sub.ivs(
          "@name" => "foo",
          "@orig_args" => Papyrus::NodeList.new(%w(foo bar baz).map {|x| Papyrus::Text.new(x) }),
          "@evaluated_args" => %w(foo bar baz)
        )
        @custom_commands = stub(:__call_inline_command__ => "the final string")
        sub.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => @custom_commands))
        @result = sub.send(:evaluates_as_custom_inline_command?)
      end

      it "should call the custom command" do
        @custom_commands.should have_received(:__call_inline_command__).with(sub)
      end

      it "should store the result of the custom command" do
        sub.ivg("@result").should == "the final string"
      end

      it "should return true" do
        @result.should == true
      end
    end

    describe "should return false" do
      it "if the command is not allowed" do
        sub.stub_methods(:command_allowed? => false)
      end

      it "if the command is allowed, but no custom command set has been given" do
        sub.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => nil))
      end

      it "if a ParserError is raised while the command is evaluated" do
        custom_commands = Object.new
        custom_commands.stub_methods_to_raise(:__call_inline_command__ => ParserError)
        sub.stub_methods(:command_allowed? => true, :template => stub(:custom_commands => custom_commands))
      end

      after do
        sub.send(:evaluates_as_custom_inline_command?).should == false
      end
    end
  end
=end
end

