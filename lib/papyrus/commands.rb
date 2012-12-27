# Papyrus comes pre-bundled with a few commands, so this file just loads them
# into the Papyrus lexicon.
#
Dir[ File.expand_path('../commands/*.rb', __FILE__) ].each {|fn| require fn }

Papyrus::Lexicon.extend_lexicon(Papyrus::Commands)


