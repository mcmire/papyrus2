
module ExampleGroupMethods; end
module ExampleMethods; end
RSpec.configure do |c|
  c.extend(ExampleGroupMethods)
  c.include(ExampleMethods)
end

module UnitExampleGroupMethods; end
module UnitExampleMethods; end
RSpec.configure do |c|
  c.extend(UnitExampleGroupMethods, :type => :unit)
  c.include(UnitExampleMethods, :type => :unit)
end
# Add /unit => :unit mapping here

module FunctionalExampleGroupMethods; end
module FunctionalExampleMethods; end
RSpec.configure do |c|
  c.extend(FunctionalExampleGroupMethods, :type => :functional)
  c.include(FunctionalExampleMethods, :type => :functional)
end
# Add /functional => :functional mapping here
