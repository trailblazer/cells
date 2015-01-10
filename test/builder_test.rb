require 'test_helper'

class BuilderTest < MiniTest::Spec
  Song = Struct.new(:title)
  Hit  = Struct.new(:title)

  class SongCell < Cell::ViewModel
    builds do |model, options|
      if model.is_a? Hit
        HitCell
      elsif options[:evergreen]
        EvergreenCell
      end
    end

    def options
      @options
    end

    def show
      "* #{title}"
    end

    property :title
  end

  class HitCell < SongCell
    def show
      "* **#{title}**"
    end
  end

  class EvergreenCell < SongCell
  end

  # the original class is used when no builder matches.
  it { Cell::ViewModel.cell("builder_test/song", nil, Song.new("Nation States"), {}).must_be_instance_of BuilderTest::SongCell }

  it do
    cell = Cell::ViewModel.cell("builder_test/song", nil, Hit.new("New York"), {})
    cell.must_be_instance_of BuilderTest::HitCell
    cell.options.must_equal({})
  end

  it do
    cell = Cell::ViewModel.cell("builder_test/song", nil, Song.new("San Francisco"), evergreen: true)
    cell.must_be_instance_of BuilderTest::EvergreenCell
    cell.options.must_equal({:evergreen=>true})
  end

  # with collection.
  it { Cell::ViewModel.cell("builder_test/song", nil, collection: [Song.new("Nation States"), Hit.new("New York")]).must_equal "* Nation States* **New York**" }

  # with Concept
  class Track < Cell::Concept
  end
  it { Cell::Concept.cell("builder_test/track", nil).must_be_instance_of Track }
end