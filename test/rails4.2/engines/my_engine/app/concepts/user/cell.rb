class User::Cell < Cell::Concept
  view_paths << "#{MyEngine::Engine.root}/app/concepts"

  def show
    # return _prefixes.inspect
    render#(view: :show)
  end
end
