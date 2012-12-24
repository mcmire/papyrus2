
#require 'papyrus/block_command'
#require 'papyrus/node_list'
#require 'papyrus/token'

module Papyrus
  class CustomBlockCommand < BlockCommand
    def initialize(*args)
      super
      @nodes = NodeList.new
      @nodes.parent = self
    end

    attr_reader :orig_args
    attr_reader :evaluated_args
    attr_reader :orig_nodes
    attr_reader :evaluated_nodes

    def active_block
      @nodes
    end

    def evaluate
      # since evaluating a NodeList can possibly mutate it, back it up
      @orig_args = @args.clone
      @evaluated_args = @args.to_a
      @orig_nodes = @nodes.clone
      @evaluated_nodes = @nodes.evaluate.join

      if evaluate? && _evaluates_as_command_or_variable?
        @raw_tokens.replace([ Token::Text.new(@result) ])
        return @result
      else
        return raw_sub
      end
    end

    def pretty_print_instance_variables
      super + ["@nodes"]
    end

    #---

    def _evaluates_as_command_or_variable?
      _evaluates_as_custom_block_command? or _evaluates_as_variable?
    end

    def _evaluates_as_custom_block_command?
      if _command_allowed? && self.template.custom_commands.class.has_block_command?(@name)
        @result = self.template.custom_commands.__call_block_command__(self)
        return true
      else
        return false
      end
    rescue ParserError => e
      #Papyrus.debug("#{e.class}: #{e.message}")
      #Papyrus.debug(e.backtrace.join("\n"))
      return false
    end
  end
end
