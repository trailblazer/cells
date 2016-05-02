lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "cell/version"

Gem::Specification.new do |spec|
  spec.name        = "cells"
  spec.version     = Cell::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["Nick Sutterer"]
  spec.email       = ["apotonick@gmail.com"]
  spec.homepage    = "https://github.com/apotonick/cells"
  spec.summary     = %q{View Models for Ruby and Rails.}
  spec.description = %q{Cells replaces partials and helpers with OOP view models, giving you proper encapsulation, inheritance, testability and a cleaner view architecture.}
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "uber", ">= 0.0.9"
  spec.add_dependency "tilt", ">= 1.4", "< 3"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "cells-erb", ">= 0.0.4"
end
