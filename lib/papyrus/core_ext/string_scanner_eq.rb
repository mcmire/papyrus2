# This file opens up StringScanner (in the Ruby standard library) and overrides
# the equality method so that `StringScanner.new("foo") ==
# StringScanner.new("foo")`, as this is not the case with the default #==
# method.
#
class StringScanner
  def ==(other)
    StringScanner === other && self.string == other.string
  end
end

