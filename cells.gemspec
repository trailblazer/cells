# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'cells/version'

Gem::Specification.new do |s|
  s.name        = "cells"
  s.version     = Cells::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "http://cells.rubyforge.org"
  s.summary     = %q{View Components for Rails.}
  s.description = %q{Cells are view components for Rails. They are lightweight controllers, can be rendered in views and thus provide an elegant and fast way for encapsulation and component-orientation.}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "actionpack",  "~> 3.0"
  s.add_dependency "railties",    "~> 3.0"
  
  s.add_development_dependency "rake"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "haml"
  s.add_development_dependency "slim"
  s.add_development_dependency "tzinfo" # FIXME: why the hell do we need this for 3.1?
  s.add_development_dependency "minitest",	">= 2.8.1"
end
