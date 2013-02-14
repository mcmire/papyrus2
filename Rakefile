
require 'fileutils'
require 'rocco'

ROOT = File.dirname(__FILE__)

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

namespace :docs do
  def build(path)
    target = path.sub("lib/", "doc/").sub(%r{\.[^\.]+$}, '.html')
    rocco_options = {
      :dir => ROOT,
      :template_file => File.join(ROOT, 'support/rocco.mustache'),
      :stylesheet => 'http://mcmire.github.com/papyrus2/rocco.css',
      :javascript => 'http://mcmire.github.com/papyrus2/rocco.js'
    }
    FileUtils.mkdir_p File.dirname(target)
    File.open(target, 'wb') do |fh|
      puts "rocco: #{path} -> #{target}"
      fh.write Papyrus::Rocco.new(path, all_paths, rocco_options).to_html
    end
  end

  def all_paths
    Dir[File.join('lib/**/*.rb')]
  end

  task "Clean up doc generation"
  task :clean do
    FileUtils.rm_rf('lib')
    FileUtils.rm_rf('doc')
  end

  task "Generate the docs for publishing to GitHub Pages"
  task :generate => :clean do
    system('git checkout master -- lib && git rm --cached -r lib')
    all_paths.each {|path| build(path) }
    system('git add doc')
  end
end

