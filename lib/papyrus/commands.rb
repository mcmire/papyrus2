
Dir[ File.expand_path('../commands/*.rb', __FILE__) ].each {|fn| require fn }

Papyrus::Lexicon.extend_lexicon(Papyrus::Commands)


