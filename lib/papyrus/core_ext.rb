# Require files that patch the Ruby core library in some way.

Dir[ File.expand_path('../core_ext/*.rb', __FILE__) ].each {|fn| require fn }
