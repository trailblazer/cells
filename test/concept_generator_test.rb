require 'test_helper'
require 'generators/rails/concept_generator'

class ConceptGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Rails::Generators::ConceptGenerator

  test "[erb] standard assets, show view" do
    run_generator %w(Song)

    assert_file "app/concepts/song/cell.rb", /class Song::Cell < Cell::Concept/
    assert_file "app/concepts/song/cell.rb", /def show/
    assert_file "app/concepts/song/views/show.erb", %r(app/concepts/song/views/show\.erb)
  end

  test "[haml] standard assets, show view" do
    run_generator %w(Song -e haml)

    assert_file "app/concepts/song/cell.rb", /class Song::Cell < Cell::Concept/
    assert_file "app/concepts/song/cell.rb", /def show/
    assert_file "app/concepts/song/views/show.haml", %r(app/concepts/song/views/show\.haml)
  end
end
