require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the hooks plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
end

require 'jeweler'
$:.unshift File.dirname(__FILE__) # add current dir to LOAD_PATHS
require 'lib/hooks'

Jeweler::Tasks.new do |spec|
  spec.name         = "hooks"
  spec.version      = ::Hooks::VERSION
  spec.summary      = %{Generic hooks with callbacks for Ruby. }
  spec.description  = "Declaratively define hooks, add callbacks and run them with the options you like."
  spec.homepage     = "http://nicksda.apotomo.de/category/hooks"
  spec.authors      = ["Nick Sutterer"]
  spec.email        = "apotonick@gmail.com"

  spec.files = FileList["[A-Z]*", File.join(*%w[{lib} ** *]).to_s]
  
  spec.add_dependency 'activesupport', '>= 2.3.0'
end

Jeweler::GemcutterTasks.new
