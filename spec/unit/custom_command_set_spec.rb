require File.dirname(__FILE__)+'/test_helper'

describe Papyrus::CustomCommandSet do
  
  before do
    @klass = Class.new(CustomCommandSet)
  end
  
  describe '.commands' do
    it "should assign @commands a new hash if it's not defined yet" do
      @klass.commands
      @klass.ivg("@commands").should == {}
    end
    it "should set the default value of the hash to a hash" do
      @klass.commands["foo"]["bar"] = "baz"
      @klass.ivg("@commands")["foo"]["bar"].should == "baz"
    end
    it "should return the value of @commands if it's already defined" do
      @klass.ivs("@commands", { :foo => "bar" })
      @klass.commands.should == { :foo => "bar" }
    end
  end
  
  describe '.aliases' do
    it "should assign @aliases a new hash if it's not defined yet" do
      @klass.aliases
      @klass.ivg("@aliases").should == {}
    end
    it "should return the value of @aliases if it's already defined" do
      @klass.ivs("@aliases", { :foo => "bar" })
      @klass.aliases.should == { :foo => "bar" }
    end
  end
  
  describe '.define_inline_command' do
    it "should store the given command in @commands as an inline command" do
      @klass.define_inline_command("foo") { }
      @klass.commands[:inline]["foo"][:block].should_not be_nil
    end
    it "should store options with the inline command" do
      @klass.define_inline_command("foo", :marlon => :wayans) { }
      @klass.commands[:inline]["foo"][:marlon].should == :wayans
    end
  end

  describe '.define_block_command' do
    it "should store the given command in @commands as an block command" do
      @klass.define_block_command("foo") { }
      @klass.commands[:block]["foo"][:block].should_not be_nil
    end
    it "should store options with the block command" do
      @klass.define_block_command("foo", :marlon => :wayans) { }
      @klass.commands[:block]["foo"][:marlon].should == :wayans
    end
  end
  
  describe '.alias_command' do
    it "should store the name of the real command under the name of the alias" do
      @klass.alias_command "jimmy", "fallon"
      @klass.ivg("@aliases")["fallon"].should == "jimmy"
    end
    it "should ensure the alias is stored lowercase" do
      @klass.alias_command "jiMmY", "fallon"
      @klass.ivg("@aliases")["fallon"].should == "jimmy"
    end
    it "should ensure the alias is stored as a string" do
      @klass.alias_command :jimmy, "fallon"
      @klass.ivg("@aliases")["fallon"].should == "jimmy"
    end
    it "should ensure the real command is stored lowercase" do
      @klass.alias_command "jimmy", "fAllOn"
      @klass.ivg("@aliases")["fallon"].should == "jimmy"
    end
    it "should ensure the real command is stored as a string" do
      @klass.alias_command "jimmy", :fallon
      @klass.ivg("@aliases")["fallon"].should == "jimmy"
    end
  end
  
  describe '.get' do
    before do
      @klass.ivs("@commands", :inline => { "froufrou" => {:block => :block} })
    end
    it "should return the info for the given command" do
      @klass.get(:inline, "froufrou").should == {:block => :block}
    end
    it "should stringify the given command before looking it up" do
      @klass.get(:inline, :froufrou).should == {:block => :block}
    end
    it "should downcase the given command before looking it up" do
      @klass.get(:inline, "fRouFRoU").should == {:block => :block}
    end
    it "should return nil if the given command does not exist" do
      @klass.get(:inline, "zingzang").should == nil
    end
    it "should return, if a valid alias is given, the info for the command the alias points to" do
      @klass.ivs("@aliases", "cheechandchong" => "froufrou")
      @klass.get(:inline, "cheechandchong").should == {:block => :block}
    end
  end
  
  describe '.set' do
    it "should store the given command and command type in @commands" do
      @klass.set(:inline, "froufrou", {:foo => :bar})
    end
    it "should stringify the given command before storing it" do
      @klass.set(:inline, :froufrou, {:foo => :bar})
    end
    it "should downcase the given command before storing it" do
      @klass.set(:inline, "fRouFRoU", {:foo => :bar})
    end
    after do
      @klass.ivg("@commands").should == { :inline => { "froufrou" => {:foo => :bar} } }
    end
  end
  
  describe '.has_inline_command?' do
    it "should return true if @commands has a command with type of :inline" do
      @klass.ivs("@commands", { :inline => {"bugger" => :something} })
      @klass.has_inline_command?("bugger").should == true
    end
    it "should return false if @commands does not have a command with type of :inline" do
      @klass.ivs("@commands", { :inline => {"slapstick" => :something} })
      @klass.has_inline_command?("bugger").should == false
    end
  end
  
  describe '.has_block_command?' do
    it "should return true if @commands has a command with type of :block" do
      @klass.ivs("@commands", { :block => {"bugger" => :something} })
      @klass.has_block_command?("bugger").should == true
    end
    it "should return false if @commands does not have a command with type of :block" do
      @klass.ivs("@commands", { :block => {"slapstick" => :something} })
      @klass.has_block_command?("bugger").should == false
    end
  end
  
  #---

  describe '.define_command' do
    it "should store the given command in @commands, merging the supplied block into the options" do
      proc = Proc.new {|x| x }
      @klass.send(:define_command, :inline, "foo", :bar => :baz, &proc)
      @klass.commands.should == { :inline => { "foo" => {:block => proc, :bar => :baz} } }
    end
  end
  
end
  
describe Papyrus::CustomCommandSet do
  
  describe '.new' do
    it "should set @template to the given template" do
      set = CustomCommandSet.new(:template, [])
      set.ivg("@template").should == :template
    end
    it "should set @args to the given args" do
      set = CustomCommandSet.new(nil, %w(foo bar))
      set.ivg("@args").should == %w(foo bar)
    end
  end
  
  describe '#dup and #clone (via #initialize_copy)' do
    it "should make a shallow copy of the args" do
      set = CustomCommandSet.new(:template, { :foo => "bar" })
      set2 = set.clone
      set2.args[:baz] = "quux"
      set.args[:baz].should be_nil
    end
  end
  
  describe '#__call_inline_command__' do
    before :each do
      @set = CustomCommandSet.new(nil, [])
      @proc = Proc.new {|args| [args, :return_value] }
    end
    it "should call the given inline command with the arrayified arguments, if the command is defined" do
      CustomCommandSet.stub_method(:get => { :block => @proc })
      sub = stub(:name => "foo", :evaluated_args => %w(foo bar))
      value = @set.send(:__call_inline_command__, sub)
      value.should == [%w(foo bar), :return_value]
    end
    it "should call the given inline command with the original argument NodeList, if the command was defined with :pre_evaluate_args => false" do
      CustomCommandSet.stub_method(:get => { :pre_evaluate_args => false, :block => @proc })
      sub = stub(:name => "foo", :orig_args => NodeList.new([ Text.new("foo") ]))
      value = @set.send(:__call_inline_command__, sub)
      value.should == [ NodeList.new([ Text.new("foo") ]), :return_value ]
    end
    it 'should call #inline_command_missing if the inline command is not defined' do
      CustomCommandSet.stub_method(:get => nil)
      @set.stub_methods(:inline_command_missing => nil)
      sub = stub(:name => "foo", :evaluated_args => %w(foo bar))
      @set.send(:__call_inline_command__, sub)
      @set.should have_received(:inline_command_missing).with("foo", %w(foo bar))
    end
  end
  
  describe '#__call_block_command__' do
    before :each do
      @set = CustomCommandSet.new(nil, [])
      @proc = Proc.new {|args, inner| [args, inner, :return_value] }
    end
    it "should call the given block command with the arrayified arguments, if the command is defined" do
      CustomCommandSet.stub_method(:get => { :block => @proc })
      sub = stub(:name => "foo", :evaluated_args => %w(foo bar), :evaluated_nodes => "quuxblargh")
      value = @set.send(:__call_block_command__, sub)
      value.should == [%w(foo bar), "quuxblargh", :return_value]
    end
    it "should call the given block command with the original argument NodeList, if the command was defined with :pre_evaluate_args => false" do
      CustomCommandSet.stub_method(:get => { :pre_evaluate_args => false, :block => @proc })
      sub = stub(:name => "foo", :orig_args => NodeList.new([ Text.new("foo") ]), :evaluated_nodes => "quuxblargh")
      value = @set.send(:__call_block_command__, sub)
      value.should == [ NodeList.new([ Text.new("foo") ]), "quuxblargh", :return_value ]
    end
    it 'should call #block_command_missing if the block command is not defined' do
      CustomCommandSet.stub_method(:get => nil)
      @set.stub_methods(:block_command_missing => nil)
      sub = stub(:name => "foo", :evaluated_args => %w(foo bar), :evaluated_nodes => "quuxblargh")
      @set.send(:__call_block_command__, sub)
      @set.should have_received(:block_command_missing).with("foo", %w(foo bar), "quuxblargh")
    end
  end
  
  #---
  
  describe '#inline_command_missing' do
    it "should raise an UnknownSubError by default" do
      lambda { CustomCommandSet.new(nil, []).send(:inline_command_missing, "", []) }.should raise_error(UnknownSubError)
    end
  end
  
  describe '#block_command_missing' do
    it "should raise an UnknownSubError by default" do
      lambda { CustomCommandSet.new(nil, []).send(:block_command_missing, "", [], []) }.should raise_error(UnknownSubError)
    end
  end
  
end