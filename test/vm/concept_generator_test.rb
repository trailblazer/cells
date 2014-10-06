require 'test_helper'
require 'rails/generators/test_case'
require 'rails/generators/concept/concept_generator'

class ConceptGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../tmp', File.dirname(__FILE__))
  setup :prepare_destination
  tests Rails::Generators::ConceptGenerator

  test '[erb] standard assets, show view' do
    run_generator %w(song)

    assert_file 'app/concepts/song/cell.rb', /class Song::Cell < Cell::Concept/
    assert_file 'app/concepts/song/cell.rb', /def show/
    assert_file 'app/concepts/song/views/show.erb', %r{app/concepts/song/views/show\.erb}
  end

  test '[haml] standard assets, show view' do
    run_generator %w(song -e haml)

    assert_file 'app/concepts/song/cell.rb', /class Song::Cell < Cell::Concept/
    assert_file 'app/concepts/song/cell.rb', /def show/
    assert_file 'app/concepts/song/views/show.haml', %r{app/concepts/song/views/show\.haml}
  end

  test '[slim] standard assets, show view' do
    run_generator %w(song -e slim)

    assert_file 'app/concepts/song/cell.rb', /class Song::Cell < Cell::Concept/
    assert_file 'app/concepts/song/cell.rb', /def show/
    assert_file 'app/concepts/song/views/show.slim', %r{app/concepts/song/views/show\.slim}
  end
end
