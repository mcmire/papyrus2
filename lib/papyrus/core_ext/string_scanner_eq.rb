
# Fix StringScanner so that StringScanner.new("foo") == StringScanner.new("foo")
class StringScanner
  def ==(other)
    StringScanner === other && self.string == other.string
  end
end

