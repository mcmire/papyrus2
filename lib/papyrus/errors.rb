
module Papyrus
  class ParserError               < ::StandardError ; end
  class UnmatchedLeftBracketError < ParserError     ; end
  class UnmatchedSingleQuoteError < ParserError     ; end
  class UnmatchedDoubleQuoteError < ParserError     ; end
  class MisplacedQuoteError       < ParserError     ; end
  class UnknownSubError           < ParserError     ; end
  class ArgumentError             < ParserError     ; end
  class UnknownVariableError      < ParserError     ; end
  class InvalidCloseSubError      < ParserError     ; end
  class UnmatchedCloseSubError    < ParserError     ; end

  class RedoEvaluation            < ::StandardError ; end  # more like a flow control thingy, but whatever
end

