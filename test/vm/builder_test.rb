require 'test_helper'

class BuilderTest < MiniTest::Spec
  Hit = Struct.new(:title)

  class SongCell < Cell::ViewModel
    build do |model, options|
      if model == Hit
        HitCell
      elsif options[:title] == "San Francisco"
        EvergreenCell
      else
        SongCell
      end
    end

    def title
      options[:title]
    end
  end

  class HitCell < SongCell
  end

  class EvergreenCell < SongCell
  end

  it { Cell::ViewModel.cell("builder_test/song", nil, Object, {}).must_be_instance_of BuilderTest::SongCell }

  it do
    cell = Cell::ViewModel.cell("builder_test/song", nil, Hit, title: "New York")
    cell.must_be_instance_of BuilderTest::HitCell
    cell.title.must_equal "New York"
  end

  it do
    cell = Cell::ViewModel.cell("builder_test/song", nil, Object, title: "San Francisco")
    cell.must_be_instance_of BuilderTest::EvergreenCell
    cell.title.must_equal "San Francisco"
  end

  # with collection
end