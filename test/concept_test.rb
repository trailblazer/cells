require 'test_helper'

# Trailblazer style:
module Record
  class Cell < Cell::Rails # cell("record")
    include Concept
    def show
      render # Party On, #{model}
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      include Concept

      def _normalize_layout(value) # 3.2+
        value
      end

      def show
        render :view => :song#, :layout => "layout"
        # TODO: test layout: .. in ViewModel
      end

      def show_with_layout
        render :view => :song, :layout => "layout"
      end
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

  unless ::Cell.rails_version.~("3.0")
    it { Record::Cell.new(@controller, "Wayne").render_state(:show).must_equal "Party on, Wayne!" }
  end


  describe "#cell" do
    it { Cell::Rails::Concept.cell("record/cell", @controller).must_be_instance_of(      Record::Cell) }
    it { Cell::Rails::Concept.cell("record/cell/song", @controller).must_be_instance_of  Record::Cell::Song }
    # cell("song", concept: "record/compilation") # record/compilation/cell/song
  end


  describe "#render with :layout" do
    it { Cell::Rails::Concept.cell("record/cell/song", @controller).show_with_layout.must_equal "<p>\nLalala\n</p>\n" }
  end
  describe "#render" do
    it { Cell::Rails::Concept.cell("record/cell/song", @controller).show.must_equal "Lalala" }
  end


  # inheriting
  it "inherit play.html.erb from BassistCell" do
    BadGuitaristCell.class_eval do
      def play; render; end
    end
    assert_equal "Doo", render_cell(:bad_guitarist, :play)
  end
end