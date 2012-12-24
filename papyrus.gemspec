
require File.expand_path('../lib/papyrus/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "papyrus"
  s.version     = Papyrus.version
  s.authors     = ["Elliot Winkler"]
  s.email       = ["elliot.winkler@gmail.com"]
  s.homepage    = "http://github.com/mcmire/papyrus"
  s.description = %q{Papyrus is a templating language...}
  s.description = %q{Papyrus is a templating language...}

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map {|f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
end
