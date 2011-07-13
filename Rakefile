# encoding: utf-8

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'cells', 'version')


desc 'Default: run unit tests.'
task :default => :test

desc 'Test the cells plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc 'Generate documentation for the cells plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cells Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('init.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# rdoc -m "README.rdoc" init.rb lib/ generators/ README.rdoc

# Gem managment tasks.
#
# == Bump gem version (any):
#
#   rake version:bump:major
#   rake version:bump:minor
#   rake version:bump:patch
#
# == Generate gemspec, build & install locally:
#
#   rake gemspec
#   rake build
#   sudo rake install
#
# == Git tag & push to origin/master
#
#   rake release
#
# == Release to Gemcutter.org:
#
#   rake gemcutter:release
#
begin
  gem 'jeweler'
  require 'jeweler'

  Jeweler::Tasks.new do |spec|
    spec.name         = "cells"
    spec.version      = ::Cells::VERSION
    spec.summary      = %{Cells are lightweight controllers for Rails and can be rendered in controllers and views, providing an elegant and fast way for encapsulation and component-orientation.}
    spec.description  = spec.summary
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
