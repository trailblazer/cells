$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "label/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "label"
  s.version     = Label::VERSION
  s.authors     = ["Nick"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Label."
  s.description = "TODO: Description of Label."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #s.add_dependency "railties", ">= 4.0.0"
end
