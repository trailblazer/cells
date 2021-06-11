lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "cell/version"

Gem::Specification.new do |spec|
  spec.name        = "cells"
  spec.version     = Cell::VERSION
  spec.authors     = ["Nick Sutterer"]
  spec.email       = ["apotonick@gmail.com"]
  spec.homepage    = "https://github.com/apotonick/cells"
  spec.summary     = "View Models for Ruby and Rails."
  spec.description = "View Models for Ruby and Rails, replacing helpers and partials while giving you a clean view architecture with proper encapsulation."
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test}/*`.split("\n")
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.2.10"

  spec.add_dependency "declarative-builder", "~> 0.2.0"
  spec.add_dependency "trailblazer-option", "~> 0.1.0"
  spec.add_dependency "tilt", ">= 1.4", "< 3"
  spec.add_dependency "uber", "< 0.2.0"

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "cells-erb", ">= 0.1.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
