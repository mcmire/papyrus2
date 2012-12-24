
require_relative '../spec_helper'

describe Papyrus::ContextItem do
  let(:wrapper_class) {
    Class.new do
      include Papyrus::ContextItem
    end
  }
  let(:wrapper) {
    wrapper_class.new
  }

  describe '@object' do
    it "has a getter and setter defined" do
      wrapper.object = :object
      expect(wrapper.object).to eq :object
    end
  end

  describe '#has_key?' do
    it "delegates to vars" do
      wrapper.vars = {'foo' => 'bar'}
      expect(wrapper.has_key?('foo')).to eq true
      expect(wrapper.has_key?('buz')).to eq false
    end
  end

  describe '#include?' do
    it "delegates to vars" do
      wrapper.vars = {'foo' => 'bar'}
      expect(wrapper.include?('foo')).to eq true
      expect(wrapper.include?('buz')).to eq false
    end
  end

  %w(get []).each do |method|
    describe "##{method}" do
      it "doesn't resolve a variable that starts with a number (even if it technically exists)" do
        wrapper.vars['342skfdlf'] = 'foo'
        expect { wrapper.__send__(method, "342skfdlf") }.to raise_error(Papyrus::UnknownVariableError)
      end

      it "stringifies the given variable name before using it" do
        stub(wrapper)._get_primary_part
        wrapper.__send__(method, :foo)
        expect(wrapper).to have_received._get_primary_part('foo', 'foo')
      end

      it "gets the primary part of the variable and then stops short if there's only one part" do
        stub(wrapper)._get_primary_part { 'some value' }
        stub(wrapper)._get_secondary_part
        value = wrapper.__send__(method, 'foo')
        expect(value).to eq 'some value'
        expect(wrapper).to_not have_received._get_secondary_part
      end

      it "resolves a multi-part variable" do
        stub(wrapper)._get_primary_part { {'bar' => 'baz'} }
        stub(wrapper)._get_secondary_part { 'baz' }
        value = wrapper.__send__(method, 'foo.bar')
        expect(value).to eq 'baz'
        wrapper.should have_received._get_secondary_part('foo.bar', 'bar', 'bar' => 'baz')
      end

      it "doesn't continue resolving a multi-part variable if it can't find the first part" do
        stub(wrapper)._get_primary_part
        stub(wrapper)._get_secondary_part
        wrapper.__send__(method, 'foo.bar')
        expect(wrapper).to_not have_received._get_secondary_part
      end
    end
  end

  %w(set []=).each do |method|
    describe "##{method}" do
      it "stores the given value in vars as the given key, stringifying and downcasing the key beforehand" do
        wrapper.__send__(method, :goUlAsh, "bar")
        expect(wrapper.vars["goulash"]).to eq "bar"
      end
    end
  end

  describe '#delete' do
    it "removes the given key from vars" do
      wrapper.vars['foo'] = 'bar'
      wrapper.delete('foo')
      expect(wrapper.vars).to_not have_key('foo')
    end
  end

  describe '#vars' do
    it "initializes @vars to a new hash on first access" do
      wrapper.vars
      expect(wrapper.vars).to eq({})
    end
  end

  describe '#vars=' do
    it "replaces @vars with the given hash" do
      wrapper.vars = {"foo" => "bar"}
      expect(wrapper.vars).to eq({"foo" => "bar"})
    end
    it "stringifies the given hash before storing it" do
      wrapper.vars = {:foo => "bar", :baz => "quux"}
      expect(wrapper.vars).to eq({"foo" => "bar", "baz" => "quux"})
    end
  end

  describe '#parser' do
    it "returns the parser of the parent node if this context has a parent" do
      parent = stub!.parser { :parser }
      stub(wrapper).parent { parent }
      expect(wrapper.parser).to eq :parser
    end

    it "returns nil if this context doesn't have a parent" do
      stub(wrapper).parent { nil }
      expect(wrapper.parser).to eq nil
    end
  end

  describe '#true?' do
    it "returns true when the given variable resolves to true" do
      stub(wrapper).get { true }
      expect(wrapper.true?("")).to eq true
    end

    it "returns true when the given variable resolves to a true-ish value" do
      stub(wrapper).get { 'foo' }
      expect(wrapper.true?("")).to eq true
    end

    it "returns false when the given variable resolves to false" do
      stub(wrapper).get { false }
      expect(wrapper.true?("")).to eq false
    end

    it "returns false when the given variable resolves to nil" do
      stub(wrapper).get { nil }
      expect(wrapper.true?("")).to eq false
    end
  end

  #---

=begin
  describe '#_get_primary_part' do
    it "should return the value of @vars' key that matches this part" do
      wrapper.ivs "@vars", {"foo" => "bar"}
      wrapper.send(:_get_primary_part, "foo", "foo").should == "bar"
    end
    it "should return the value of @object's key that matches this part, if @object is a hash" do
      wrapper.ivs "@object", {"foo" => "bar"}
      wrapper.send(:_get_primary_part, "foo", "foo").should == "bar"
    end
    it "should return the value of @object's key that matches this part (as a symbol), if @object is a hash" do
      wrapper.ivs "@object", {:foo => "bar"}
      wrapper.send(:_get_primary_part, "foo", "foo").should == "bar"
    end
    it "should return the value of @object's method that matches this part" do
      mock = Object.stub_instance(:foo => "bar")
      wrapper.ivs "@object", mock
      value = wrapper.send(:_get_primary_part, "foo", "foo")
      value.should == "bar"
      mock.should have_received(:foo)
    end
    it "should try to resolve this part in the parent context as a last resort" do
      parent = Object.stub_instance(:get => "bar")
      wrapper.ivs "@parent", parent
      value = wrapper.send(:_get_primary_part, "foo", "foo")
      parent.should have_received(:get).with("foo")
      value.should == "bar"
    end
    it "should raise UnknownVariableError if this part could not be resolved" do
      lambda { wrapper.send(:_get_primary_part, "foo", "foo") }.should raise_error(UnknownVariableError)
    end
  end

  describe '#_get_secondary_part' do
    it "should return the value of @vars' key that matches this part" do
      wrapper.ivs "@vars", {"foo.bar" => "baz"}
      wrapper.send(:_get_secondary_part, "foo.bar", "bar", nil).should == "baz"
    end
    describe "when value-so-far is not nil" do
      it "should treat this part as a key in the value-so-far, if it's a hash" do
        wrapper.send(:_get_secondary_part, "foo.bar", "bar", {"bar" => "baz"}).should == "baz"
      end
      it "should treat this part as an index of the value-so-far, if it's an array" do
        wrapper.send(:_get_secondary_part, "foo.1", "1", [ "quux", "baz" ]).should == "baz"
      end
      it "should return the value of the value-so-far's method that matches this part" do
        mock = Object.stub_instance(:bar => 'baz')
        wrapper.send(:_get_secondary_part, "foo.bar", "bar", mock).should == "baz"
      end
      it "should raise UnknownVariableError if value-so-far has no method that matches this part" do
        mock = Object.stub_instance(:joe => 'bloe')
        lambda { wrapper.send(:_get_secondary_part, "foo.bar", "bar", mock) }.should raise_error(UnknownVariableError)
      end
    end
    it "should raise UnknownVariableError if this part could not be resolved" do
      lambda { wrapper.send(:_get_secondary_part, "foo.bar", "foo", nil) }.should raise_error(UnknownVariableError)
    end
  end
=end
end
