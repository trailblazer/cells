require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'cells', 'version')


desc 'Default: run unit tests.'
task :default => :test

desc 'Test the cells plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = FileList['test/*_test.rb', 'test/rails/*_test.rb']
  test.verbose = true
end

begin
  gem 'jeweler'
  require 'jeweler'

  Jeweler::Tasks.new do |spec|
    spec.name         = "cells"
    spec.version      = ::Cells::VERSION
    spec.summary      = %{View Components for Rails.}
    spec.description  = %{Cells are lightweight controllers for Rails and can be rendered in views, providing an elegant and fast way for encapsulation and component-orientation.}
    spec.homepage     = "http://cells.rubyforge.org"
    spec.authors      = ["Nick Sutterer"]
    spec.email        = "apotonick@gmail.com"

    spec.files = FileList["[A-Z]*", File.join(*%w[{lib,rails,rails_generators} ** *]).to_s]

    # spec.add_dependency 'activesupport', '>= 2.3.0' # Dependencies and minimum versions?
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler - or one of its dependencies - is not available. " <<
  "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end
