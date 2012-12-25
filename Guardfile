
guard('rspec',
  :all_on_start => false,
  :all_after_pass => false,
  :keep_failed => false,
  :bundler => false
) do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/papyrus/(.+)\.rb$})     { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'rocco', :dir => 'doc/rocco' do
  watch(%r{^lib/(.*)\.rb$})
end
