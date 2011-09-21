require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc 'Test the cells gem.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = FileList['test/*_test.rb', 'test/rails/*_test.rb'] - ['test/rails/capture_test.rb']
  test.verbose = true
end
