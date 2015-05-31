require "my_engine/engine"

module MyEngine
  # This also works
  # Cell::Concept.view_paths << File.expand_path("#{MyEngine::Engine.root}/app/concepts", __FILE__)
end
