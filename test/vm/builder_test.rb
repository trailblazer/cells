require 'test_helper'

class BuilderTest < MiniTest::Spec
  Song = Struct.new(:title)
  Hit  = Struct.new(:title)

  class SongCell < Cell::ViewModel
    build do |model, options|
      if model.is_a? Hit
        HitCell
      elsif options[:evergreen]
        EvergreenCell
      else
        SongCell
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

  # with collection

  it do
    Cell::ViewModel.cell("builder_test/song", nil, collection: [Song.new("Nation States"), Hit.new("New York")]).must_equal "* Nation States\n* **New York**"
  end
end