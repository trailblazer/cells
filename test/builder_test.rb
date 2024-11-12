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
  it { _(SongCell.(Song.new("Nation States"), {})).must_be_instance_of SongCell }

  it do
    cell = SongCell.(Hit.new("New York"), {})
    _(cell).must_be_instance_of HitCell
    _(cell.options).must_equal({})
  end

  it do
    cell = SongCell.(Song.new("San Francisco"), evergreen: true)
    _(cell).must_be_instance_of EvergreenCell
    _(cell.options).must_equal({evergreen:true})
  end

  # without arguments.
  it { _(SongCell.(Hit.new("Frenzy"))).must_be_instance_of HitCell }

  # with collection.
  it { _(SongCell.(collection: [Song.new("Nation States"), Hit.new("New York")]).()).must_equal "* Nation States* **New York**" }

  # with Concept
  class Track < Cell::Concept
  end
  it { _(Track.()).must_be_instance_of Track }
end
