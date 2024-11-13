require 'test_helper'

class BuilderTest < Minitest::Spec
  Song = Struct.new(:title)
  Hit  = Struct.new(:title)

  class SongCell < Cell::ViewModel
    include Cell::Builder

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
  it { assert_instance_of SongCell, SongCell.(Song.new("Nation States"), {}) }

  it do
    cell = SongCell.(Hit.new("New York"), {})
    assert_instance_of HitCell, cell
    assert_equal({}, cell.options)
  end

  it do
    cell = SongCell.(Song.new("San Francisco"), evergreen: true)
    assert_instance_of EvergreenCell, cell
    assert_equal({evergreen: true}, cell.options)
  end

  # without arguments.
  it { assert_instance_of HitCell, SongCell.(Hit.new("Frenzy")) }

  # with collection.
  it { assert_equal "* Nation States* **New York**", SongCell.(collection: [Song.new("Nation States"), Hit.new("New York")]).() }

  # with Concept
  class Track < Cell::Concept
  end
  it { assert_instance_of Track, Track.() }
end
