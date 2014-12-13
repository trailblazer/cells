require 'test_helper'

Cell::Concept.class_eval do
  self.view_paths = ['test/fixtures/concepts']
end

# Trailblazer style:
module Record
  class Cell < Cell::Concept # cell("record")
    self.template_engine = "erb"

    def show
      render # Party On, #{model}
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      def show
        render :view => :song#, :layout => "layout"
        # TODO: test layout: .. in ViewModel
      end
    end

    class Hit < ::Cell::Concept
      inherit_views Record::Cell
    end
  end
end

# app/cells/comment/views
# app/cells/comment/form/views
# app/cells/comment/views/form inherit_views Comment::Cell, render form/show


class ConceptTest < MiniTest::Spec
  describe "::controller_path" do
    it { Record::Cell.new(@controller).controller_path.must_equal "record" }
    it { Record::Cell::Song.new(@controller).controller_path.must_equal "record/song" }
  end


  describe "#_prefixes" do
    it { Record::Cell.new(@controller)._prefixes.must_equal       ["record/views"] }
    it { Record::Cell::Song.new(@controller)._prefixes.must_equal ["record/song/views", "record/views"] }
    it { Record::Cell::Hit.new(@controller)._prefixes.must_equal  ["record/hit/views", "record/views"]  } # with inherit_views.
  end

  it { Record::Cell.new(@controller, "Wayne").call(:show).must_equal "Party on, Wayne!" }


  describe "#cell" do
    it { Cell::Concept.cell("record/cell", @controller).must_be_instance_of(      Record::Cell) }
    it { Cell::Concept.cell("record/cell/song", @controller).must_be_instance_of  Record::Cell::Song }
    # cell("song", concept: "record/compilation") # record/compilation/cell/song
  end

  describe "#render" do
    it { Cell::Concept.cell("record/cell/song", @controller).show.must_equal "Lalala" }
  end
end
