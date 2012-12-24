
module Papyrus
  class Lexicon
    def self.commands
      @commands ||= {}
    end

    def self.extensions
      @extensions ||= []
    end

    # Add the name of a command along with the class that represents that
    # command to the global commands hash.
    #
    def self.add_command(name, klass)
      name = name.to_sym
      commands[name] = klass
    end

    # Given a module that contains classes representing commands, add the
    # commands to the lexicon. The name of the command is derived from the name
    # of the class (so an Include class would be assumed to represent the
    # 'include' command).
    #
    def self.extend_lexicon(mod)
      return if extensions.include?(mod)
      mod.constants.each do |constant|
        command_name = constant.downcase
        command_class = mod.const_get(constant)
        if Class === command_class
          add_command(command_name, command_class)
        end
      end
      extensions << mod
    end
  end
end
