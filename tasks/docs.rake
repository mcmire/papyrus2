
namespace :docs do
  task :generate do
    puts "Compiling documentation..."
    guard = Guard.guards.find {|guard| Guard::Rocco === guard }
    guard.run_all
  end
end
