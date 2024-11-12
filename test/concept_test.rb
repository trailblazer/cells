require 'test_helper'

Cell::Concept.class_eval do
  self.view_paths = ['test/fixtures/concepts']
end

# Trailblazer style:
module Record
  class Cell < ::Cell::Concept # cell("record")
    include ::Cell::Erb

    def show
      render # Party On, #{model}
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      def show
        render view: :song#, layout: "layout"
        # TODO: test layout: .. in ViewModel
      end
    end

    class Hit < ::Cell::Concept
      inherit_views Record::Cell
    end


    def description
      "A Tribute To Rancid, with #{@options[:tracks]} songs! [#{context}]"
    end
  end
end

module Record
  module Cells
    class Cell < ::Cell::Concept
      class Song < ::Cell::Concept
      end
    end
  end
end

# app/cells/comment/views
# app/cells/comment/form/views
# app/cells/comment/views/form inherit_views Comment::Cell, render form/show


class ConceptTest < Minitest::Spec
  describe "::controller_path" do
    it { assert_equal("record", Record::Cell.new.class.controller_path) }
    it { assert_equal("record/song", Record::Cell::Song.new.class.controller_path) }
    it { assert_equal("record/cells", Record::Cells::Cell.new.class.controller_path) }
    it { assert_equal("record/cells/song", Record::Cells::Cell::Song.new.class.controller_path) }
  end


  describe "#_prefixes" do
    it { assert_equal(["test/fixtures/concepts/record/views"], Record::Cell.new._prefixes) }
    it { assert_equal(["test/fixtures/concepts/record/song/views", "test/fixtures/concepts/record/views"], Record::Cell::Song.new._prefixes) }
    it { assert_equal(["test/fixtures/concepts/record/hit/views", "test/fixtures/concepts/record/views"], Record::Cell::Hit.new._prefixes) } # with inherit_views.
  end

  it { assert_equal("Party on, Wayne!", Record::Cell.new("Wayne").call(:show)) }


  describe "::cell" do
    it { assert_instance_of(Record::Cell, Cell::Concept.cell("record/cell")) }
    it { assert_instance_of(Record::Cell::Song, Cell::Concept.cell("record/cell/song")) }
    # cell("song", concept: "record/compilation") # record/compilation/cell/song
  end

  describe "#render" do
    it { assert_equal("Lalala", Cell::Concept.cell("record/cell/song").show) }
  end

  describe "#cell (in state)" do
    # test with controller, but remove tests when we don't need it anymore.

    it { assert_instance_of(Record::Cell, Cell::Concept.cell("record/cell", nil, context: { controller: Object }).cell("record/cell", nil)) }

    it do
      result = Cell::Concept.cell("record/cell", nil, context: { controller: Object })
        .concept("record/cell", nil, tracks: 24).(:description)

      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
        assert_equal("A Tribute To Rancid, with 24 songs! [{:controller=>Object}]", result)
      else
        assert_equal("A Tribute To Rancid, with 24 songs! [{controller: Object}]", result)
      end
    end

    # concept(.., collection: ..)
    it do
      result = Cell::Concept.cell("record/cell", nil, context: { controller: Object }).
        concept("record/cell", collection: [1,2], tracks: 24).(:description)

      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
        assert_equal("A Tribute To Rancid, with 24 songs! [{:controller=>Object}]A Tribute To Rancid, with 24 songs! [{:controller=>Object}]", result)
      else
        assert_equal("A Tribute To Rancid, with 24 songs! [{controller: Object}]A Tribute To Rancid, with 24 songs! [{controller: Object}]", result)
      end
    end
  end
end
