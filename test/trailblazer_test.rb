require 'test_helper'

class RecordCell < Cell::Rails
  class SongCell < self
    def show
      render
    end
  end
end

# Trailblazer style:
module Record
  class Cell < Cell::Rails # cell("record")
    include Concept
    def show
      render
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      include Concept
    end

    class Hit < ::Cell::Rails
      include Concept

      inherit_views Record::Cell
    end
  end
end

# app/cells/comment/views
# app/cells/comment/form/views
# app/cells/comment/views/form inherit_views Comment::Cell, render form/show


class ConceptTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  describe "::controller_path" do
    it { Record::Cell.new(@controller).controller_path.must_equal "record" }
    it { Record::Cell::Song.new(@controller).controller_path.must_equal "record/song" }
  end

  describe "#_prefixes" do
    it { Record::Cell.new(@controller)._prefixes.must_equal       ["record/views"] }
    it { Record::Cell::Song.new(@controller)._prefixes.must_equal ["record/song/views", "record/views"] }
    it { Record::Cell::Hit.new(@controller)._prefixes.must_equal  ["record/hit/views", "record/views"]  } # with inherit_views.
  end

  it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }


  describe "#cell" do
    it { Cell::Rails::Concept.cell("record/cell", @controller).must_be_instance_of(      Record::Cell) }
    it { Cell::Rails::Concept.cell("record/cell/song", @controller).must_be_instance_of  Record::Cell::Song }
    # cell("song", concept: "record/compilation") # record/compilation/cell/song
  end


  # inheriting
  it "inherit play.html.erb from BassistCell" do
    BadGuitaristCell.class_eval do
      def play; render; end
    end
    assert_equal "Doo", render_cell(:bad_guitarist, :play)
  end

  it "inherit show.erb from parent" do
    render_cell("record_cell/song", :show).must_equal "Rock on!"
  end
end