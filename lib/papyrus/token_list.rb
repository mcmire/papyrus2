
#require 'papyrus/token'

module Papyrus
  # A TokenList is, well, a list of tokens. In fact it's nothing more than an
  # Array that has the ability to step through its items one at a time and know
  # which item it's currently on.
  #
  class TokenList < ::Array
    # Create a new TokenList using the given array.
    #
    def self.[](*list)
      arr = self.new
      arr.replace(list)
      arr
    end

    # Create a new TokenList.
    #
    def initialize
      @pos = -1
    end

    # The token pointer, i.e., the index of the token that's currently selected.
    attr_accessor :pos

    # If we're currently inside a sub and the last item on this TokenList is
    # another TokenList, adds the given token to that TokenList, otherwise adds
    # the token to the main TokenList.
    #
    def add(token)
      if TokenList === self.last and not Token::RightBracket === self.last.last
        self.last << token
      else
        self << token
      end
    end

    # Increment the token pointer and returns the token at that index.
    # Whitespace tokens will be skipped over.
    #
    # If @stash_curr_on_advance is true, everything that's encountered will be
    # stored in the @stash, even whitespace.
    #
    def advance
      @pos += 1
      self[@pos]
    end

    # Get the currently selected token.
    #
    def curr
      self[@pos]
    end

    # Get the token following the current one.
    #
    def next
      self[@pos+1]
    end

    # Get the token before the current one.
    #
    def prev
      self[@pos-1]
    end

    # Ensuring that this TokenList doesn't have any sub-TokenLists, join
    # all the Tokens into a single string.
    #
    def to_s
      self.flatten.join
    end
  end
end
