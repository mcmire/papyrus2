# An InlineSub is one of the three types of nodes that the Parser uses to build
# the Document object. It is used to represent a sub like `[foo]`, which cannot
# be resolved immediately. We know this is an inline sub,
# because it doesn't look like a block command (otherwise it would be
# `[foo]..[/foo]`). What we *don't* know (since it doesn't have any arguments)
# is what kind of inline sub it is -- does it refer to a built-in command, a
# custom command, or a variable? We can only know this at runtime. In the
# meantime, we need an object of *some* kind, so we use InlineSub as a
# placeholder.

# ## Public interface
module Papyrus
  class InlineSub < Sub
    # ### Properties

    # #### orig_args
    #
    # A NodeList, this is a backup of the `args` argument given to the
    # initializer. It exists because #evaluate will destructively modify @args.
    #
    attr_reader :orig_args

    # #### evaluated_args
    #
    # The Array<String> evaluated version of @args.
    #
    attr_reader :evaluated_args

    # ### Methods

    # #### InlineSub#evaluate
    #
    # Resolves the sub and turns it into a String.
    #
    # This is where we determine what exactly the sub actually represents:
    # a built-in command, a custom command, a variable, or nothing.
    #
    # If the sub is successfully evaluated, returns the String result of the
    # evaluation, otherwise returns the String unevaluated representation of the
    # command as it originally appeared in the document.
    #
    def evaluate
      # Since evaluating a NodeList can possibly mutate it, back it up.
      @orig_args = @args.clone
      @evaluated_args = @args.to_a

      if evaluate? && _evaluates_as_inline_command_or_variable?
        # The sub was resolved successfully. Update the raw token list to
        # contain merely the result so that if an outer sub cannot be resolved,
        # the result of this sub will still be retained. This works because
        # there's actually a reference to this `raw_tokens` object in the
        # `raw_tokens` array of the parent sub, and so changing this object
        # changes that one (and any other references up the ancestry chain) too.
        # Neat, eh?
        @raw_tokens.replace([ Token::Text.new(@result) ])
        return @result
      else
        return raw_sub
      end
    end

    # ## Private interface

    # ### Methods

    # #### InlineSub#_evaluates_as_inline_command_or_variable?
    #
    # ...
    #
    def _evaluates_as_inline_command_or_variable?
      _evaluates_as_builtin_command? or
      _evaluates_as_custom_inline_command? or
      _evaluates_as_variable?
    end

    # #### InlineSub#_evaluates_as_builtin_command?
    #
    # ...
    #
    def _evaluates_as_builtin_command?
      # We should probably put a restriction on the built-in command lookup
      # because not all built-in commands may be inline. Right now we only have
      # one and it is inline, so this is okay but we need to clean this up.
      if _command_allowed? and cmd_class = Papyrus::Lexicon.commands[@name]
        cmd = cmd_class.new(@name, @orig_args, @raw_tokens)
        cmd.parent = @parent
        cmd.wrapper = self
        @result = cmd.evaluate
        return true
      else
        return false
      end
    rescue ParserError => e
      return false
    end

    def _evaluates_as_custom_inline_command?
      if command_allowed? && self.template.custom_commands
        @result = self.template.custom_commands.__call_inline_command__(self)
        return true
      else
        return false
      end
    rescue ParserError => e
      return false
    end
  end
end

