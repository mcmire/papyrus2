
root = File.expand_path('..', __FILE__)

require 'rocco'

module Papyrus
  class Rocco < ::Rocco
    class Render < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants
    end

    def process_markdown(text)
      @renderer ||= Redcarpet::Markdown.new(Render)
      @renderer.render(text)
    end
  end
end

=begin
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
=end

guard 'sass', :input => "doc", :output => "doc/rocco"

guard 'rocco', {
  :rocco_class => Papyrus::Rocco,
  :dir => 'doc/rocco',
  :stylesheet => "file://#{root}/doc/rocco/rocco.css",
  :template_file => "#{root}/doc/rocco.mustache"
} do
  watch(%r{^lib/(.*)\.rb$})
end
