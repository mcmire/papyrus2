
namespace :docs do
  task "Generate the docs for publishing to GitHub Pages"
  task :generate do
    commands = [
      'rm -rf lib',
      'git checkout master -- lib',
      'rocco lib',
      'rm -rf lib'
    ]
    system commands.join(' &&' )
  end
end
