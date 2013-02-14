# The Include class represents an `[include]` sub, which can be used to insert
# content from another source into the current template.
#
module Papyrus
  module Commands
    class Include < Command
      # The InsertionSub module provides #parse_and_insert_into_parent.
      include InsertionSub

      # ## Public methods

      # #### Include#get_template_source
      #
      # Gets the content that will be inserted into the current template.
      #
      # You must override this method in a subclass. It must return the NodeList
      # template content that will replace this sub.
      #
      def get_template_source
        raise NotImplementedError, <<-EOT.squeeze(" ")
          Include#get_template_source must be implemented by a subclass. It
          should return the template content that will replace [include].
        EOT
      end

      # #### Include#evaluate
      #
      # Runs the content retrieved by #get_template_source through the parser
      # and insert the resulting nodes into the document that is currently being
      # evaluated.
      #
      # Returns the String evaluated content.
      #
      def evaluate
        @evaluated_args = @args.to_a
        @template_name = @evaluated_args.first
        raise ArgumentError, "Template name was not given" unless @template_name
        get_template_source.tap do |content|
          parse_and_insert_into_parent(content)
        end
      end
    end
  end
end
