
root = File.expand_path('..', __FILE__)

guard 'rspec', {
  :all_on_start => false,
  :all_after_pass => false,
  :keep_failed => false,
  :bundler => false
} do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/papyrus/(.+)\.rb$})     { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'sass', :input => "doc", :output => "doc/rocco"

guard 'rocco', {
  :dir => 'doc/rocco',
  :stylesheet => "file://#{root}/doc/rocco/rocco.css",
  :template_file => "#{root}/doc/rocco.mustache"
} do
  watch(%r{^lib/(.*)\.rb$})
end
