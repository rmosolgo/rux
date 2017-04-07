require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end


# Build the extension named `rux`
Rake::ExtensionTask.new "rux" do |ext|
  # Put the compiled file in `lib/rux/`
  ext.lib_dir = "lib/rux"
end

task :default => :compile
task :default => :test
