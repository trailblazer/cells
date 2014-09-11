require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = FileList['test/vm/*_test.rb']
  test.verbose = true
end
