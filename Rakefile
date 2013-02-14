
require 'fileutils'
require 'rocco'

ROOT = File.dirname(__FILE__)
LIBPATH = File.join(ROOT, 'lib')
DOCPATH = File.join(ROOT, 'doc')

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
    target = path.sub("lib/", "").sub(%r{\.[^\.]+$}, '.html')
    rocco_options = {
      :dir => ROOT,
      :template_file => File.join(ROOT, 'support/rocco.mustache'),
      :stylesheet => File.join(ROOT, 'rocco.css'),
      :javascript => File.join(ROOT, 'rocco.js')
    }
    FileUtils.mkdir_p File.dirname(target)
    File.open(target, 'wb') do |fh|
      puts "rocco: #{path} -> #{target}"
      fh.write Papyrus::Rocco.new(path, all_paths, rocco_options).to_html
    end
  end

  def all_paths
    Dir[File.join(LIBPATH, '**/*.rb')]
  end

  def clear_lib
    system("git rm --cached -rf #{LIBPATH} && rm -rf #{LIBPATH}")
  end

  task "Generate the docs for publishing to GitHub Pages"
  task :generate do
    clear_lib
    system('git checkout master -- lib')
    all_paths.each {|path| build(path) }
    system('git add *.html && git add papyrus/*.html')
    clear_lib
  end
end

