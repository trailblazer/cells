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

task :rails do
  Bundler.with_clean_env do
    Dir.chdir("test/rails4.2") do
      sh "bundle exec rake", verbose: false do
        # Do nothing if suite fails, allowing us to see the results for all of
        # them, even if some of the suites have failing tests
      end
    end
  end
end

# rails_task = Rake::Task["rails"]
# test_task = Rake::Task["test"]
# default_task.enhance { test_task.invoke }
# default_task.enhance { rails_task.invoke }
