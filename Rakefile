require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "cells"
SUMMARY = %{Cells are lightweight controllers for Rails and can be rendered in controllers and views, providing an elegant and fast way for encapsulation and component-orientation.}
HOMEPAGE = "http://cells.rubyforge.org"
AUTHORS = ["Nick Sutterer"]
EMAIL = "apotonick@gmail.com"
SUPPORT_FILES = %w[README CHANGES]

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the cells plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the cells plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cells Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
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
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = NAME
    gemspec.summary     = SUMMARY
    gemspec.description = SUMMARY
    gemspec.homepage    = HOMEPAGE
    gemspec.authors     = AUTHORS
    gemspec.email       = EMAIL
    
    gemspec.require_paths = %w{lib}
    gemspec.files = FileList["[A-Z]*", File.join(*%w[{generators,lib} ** *]).to_s, "init.rb"]
    gemspec.extra_rdoc_files = SUPPORT_FILES
    
    # gemspec.add_dependency 'activesupport', '>= 2.3.0' # Dependencies and minimum versions?
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler - or one of its dependencies - is not available. " <<
        "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end
