class Album::Cell < Cell::Concept
  view_paths << "#{MyEngine::Engine.root}/app/concepts"
  self.assets_paths = ["assets"]

  def show
    render
  end
end
