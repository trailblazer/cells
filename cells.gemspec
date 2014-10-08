lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'cell/version'

Gem::Specification.new do |spec|
  spec.name        = "cells"
  spec.version     = Cell::VERSION::STRING
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["Nick Sutterer"]
  spec.email       = ["apotonick@gmail.com"]
  spec.homepage    = "http://cells.rubyforge.org"
  spec.summary     = %q{View Models for Rails.}
  spec.description = %q{Cells replace partials and helpers with OOP view models, giving you proper encapsulation, inheritance, testability and a cleaner view architecture.}
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack",  ">= 3.0"
  spec.add_dependency "railties",    ">= 3.0"
  spec.add_dependency "uber",        "~> 0.0.9"
  spec.add_dependency 'tilt', '>= 1.3', '< 3'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "tzinfo" # FIXME: why the hell do we need this for 3.1?
  spec.add_development_dependency "minitest",	"~> 5.4.1"
  spec.add_development_dependency "test_xml"
  spec.add_development_dependency "activemodel"
  # spec.add_development_dependency "activerecord"
  # spec.add_development_dependency "sqlite3"


  spec.add_development_dependency "capybara"
  spec.add_development_dependency "sprockets"
  spec.add_development_dependency "disposable", "~> 0.0.8"
end
