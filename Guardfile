
root = File.expand_path('..', __FILE__)

require 'rocco'

module Papyrus
  class Rocco < ::Rocco
    class Render < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants

      def block_code(code, language)
        language ||= 'raw'
        Pygments.highlight(code, {
          :lexer   => language,
          :options => {
            :outencoding => 'utf-8'
          }
        })
      end
    end

    def process_markdown(text)
      text.gsub!('--', '---')
      text.gsub!(/\|\|(.+?)\|\|/, %{<span class="args">\\1</span>})

      @renderer ||= Redcarpet::Markdown.new(Render,
        :fenced_code_blocks => true,
        :no_intra_emphasis => true, # GFM
        :tables => true,
        :space_after_headers => true
      )
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
  :template_file => "#{root}/doc/rocco.mustache",
  :stylesheet => "file://#{root}/doc/rocco/rocco.css",
  :javascript => "file://#{root}/doc/rocco.js",
} do
  watch(%r{^lib/(.*)\.rb$})
end
