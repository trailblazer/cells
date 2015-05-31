require "cells"
puts "eingiiiiiiine loaded"
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine
    # This also works
    # Cell::Concept.view_paths << File.expand_path("#{MyEngine::Engine.root}/app/concepts", __FILE__)
  end
end
