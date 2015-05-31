require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/*_test.rb'
  test.verbose = true
end

# Rake::TestTask.new(:rails) do |test|
#   test.libs << 'test/rails'
#   test.test_files = FileList['test/rails4.2/*_test.rb']
#   test.verbose = true
# end

# rails_task = Rake::Task["rails"]
# test_task = Rake::Task["test"]
# default_task.enhance { test_task.invoke }
# default_task.enhance { rails_task.invoke }