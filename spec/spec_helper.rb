
require 'pp'

require 'rspec'

Dir[ File.expand_path('../support/*.rb', __FILE__) ].each {|fn| require fn }

$:.unshift File.expand_path('../../lib', __FILE__)
require 'papyrus'
