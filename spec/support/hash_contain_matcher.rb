
module Enumerable
  def contain?(other)
    self.class === other && other.all? {|x| include?(x) }
  end
end

class Hash
  def contain?(other)
    self.class === other && other.all? {|k,v| self[k] == v }
  end
end

RSpec::Matchers.define :contain do |other|
  match do |enum|
    enum.respond_to?(:contain?) && enum.contain?(other)
  end
  failure_message_for_should do |enum|
    "expected #{enum.inspect} to contain #{other.inspect}, but it didn't"
  end
  failure_message_for_should_not do |enum|
    "expected #{enum.inspect} to not contain #{other.inspect}, but it did"
  end
  description do
    "should contain #{other.inspect}"
  end
end

