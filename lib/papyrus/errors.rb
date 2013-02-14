# This file holds all of the exceptions that Papyrus may raise.

module Papyrus
  # ## Parser errors

  # #### ParserError
  #
  # Raised by the Parser if it has a problem reading or evaluating a sub.
  #
  ParserError = Class.new(StandardError)

  # #### UnmatchedLeftBracketError
  #
  # Raised if, at the start of a sub or within a sub, the parser sees a `[` but
  # never sees a matching `]` before the end of the text document is reached.
  #
  # ||Examples:||
  #
  # * `[foo`
  # * `[foo [bar]`
  #
  UnmatchedLeftBracketError = Class.new(ParserError)

  # #### UnmatchedSingleQuoteError
  #
  # Raised if, at the start of a sub or within a sub, the parser sees an opening
  # `'` but never sees a matching `'` before the end of the text document is
  # reached.
  #
  # ||Examples:||
  #
  # * `[foo 'this is great]`
  # * `[foo 'this is great`
  #
  UnmatchedSingleQuoteError = Class.new(ParserError)

  # #### UnmatchedDoubleQuoteError
  #
  # Raised if, at the start of a sub or within a sub, the parser sees an opening
  # `"` but never sees a matching `"` before the end of the text document is
  # reached.
  #
  # ||Examples:||
  #
  # * `[foo "this is great]`
  # * `[foo "this is great`
  #
  UnmatchedDoubleQuoteError = Class.new(ParserError)

  # #### MisplacedQuoteError
  #
  # Raised if, within a sub, the parser encounters a `'` or `"` in the middle of
  # a word.
  #
  # ||Examples:||
  #
  # * `[foo"bar"]`
  # * `[foo"bar"baz]`
  # * `[foo"bar" baz]`
  # * `[foo "bar"baz]`
  # * `[foo'bar']`
  # * `[foo'bar'baz]`
  # * `[foo'bar' baz]`
  # * `[foo 'bar'baz]`
  #
  MisplacedQuoteError = Class.new(ParserError)

  # #### UnknownSubError
  #
  # Raised if the parser encounters a bracketed expression that appears to be a
  # sub but is malformed.
  #
  # ||Example:||
  #
  # * `[1092]`
  # * `[steve's]`
  # * `[[foo] bar]` (where `[foo]` resolves to nothing)
  #
  UnknownSubError = Class.new(ParserError)

  # #### UnknownVariableError
  #
  # Raised when the parser attemps to resolve a Variable and the variable is not
  # registered in any context.
  #
  UnknownVariableError = Class.new(ParserError)

  # #### InvalidCloseSubError
  #
  # Raised if the parser encounters a bracketed expression that appears to be
  # the close of a block command, but is malformed.
  #
  # ||Example:||
  #
  # * `[/09213]`
  # * `[/steve's]`
  #
  InvalidCloseSubError = Class.new(ParserError)

  # #### UnmatchedCloseSubError
  #
  # Raised if the parser encounters a bracketed expression that appears to be
  # the close of a block command, but the name of the command it refers to
  # doesn't exist.
  #
  # ||Example:||
  #
  # * `[foo]...[/bar]`
  #
  UnmatchedCloseSubError = Class.new(ParserError)

  # ## Other errors

  # #### RedoEvaluation
  #
  # Raised while evaluating the contents of a Variable. As the value of a
  # Variable may be a Variable itself, and that Variable may resolve to another
  # Variable, we have to descend into the AST until it resolves into a Text
  # node. This exception (which isn't really an exception, it's more of a flow
  # control thing) just tells Papyrus to keep on going.
  #
  RedoEvaluation = Class.new(StandardError)
end

