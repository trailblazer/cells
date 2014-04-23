require 'test_helper'

class RecordCell < Cell::Rails
  class SongCell < self
    def show
      render
    end
  end
end

Cell::Rails.class_eval do
  module Concept
    module ClassMethods
      def controller_path
        # TODO: cache on class level
        # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
        # applies to Comment::Cell, Comment::Cell::Form, etc.
        name.sub(/::Cell/, '').underscore  unless anonymous?
      end

      def inherit_views(parent)
        # define_method :parent_prefixes do
        #   ["record"]
        # end
        #_prefixes = _prefixes + [parent._prefixes]
      end
    end

    extend ActiveSupport::Concern
    included do
      extend ClassMethods
    end
  end
end

# Trailblazer style:
module Record
  class Cell < Cell::Rails # cell("record")
    include Concept
    # prefix: record/
    #         record/views/
    def show
      render
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      include Concept
    # prefix: record/song/
    #         record/song/views/
    #         record/
    #         record/views/
    end

    class Hit < ::Cell::Rails
      include Concept

      inherit_views Record::Cell
    end
  end
end


class TrailblazerTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

    describe "::controller_path" do
      it { Record::Cell.new(@controller).controller_path.must_equal "record" }
      it { Record::Cell::Song.new(@controller).controller_path.must_equal "record/song" }
    end

    describe "#_prefixes" do
      it { Record::Cell.new(@controller)._prefixes.must_equal       ["record"] }
      it { Record::Cell::Song.new(@controller)._prefixes.must_equal ["record/song", "record"] }
    end

    it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }


    describe "#cell" do
      it { cell("record").must_be_instance_of(      Record::Cell) } # record/cell
      it { cell("record/song").must_be_instance_of  Record::Cell::Song } # record/cell/song
      # cell("song", concept: "record/compilation") # record/compilation/cell/song
    end


    describe "::inherit_views" do
      it { Record::Cell::Hit.new(@controller)._prefixes.must_equal ["record/hit", "record"]  }
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



# default behaviour:
  unless Cell.rails3_0?
    # class AlbumCell < Rails::Cell
    class AlbumCell < Cell::Rails
      class SongCell < self
      end
    end

    describe "#_prefixes" do
      it { cell("trailblazer_test/album")._prefixes.must_equal(          ["trailblazer_test/album"]) }
      it { cell("trailblazer_test/album_cell/song")._prefixes.must_equal(["trailblazer_test/album_cell/song", "trailblazer_test/album"]) } # this is semi-cool, but the old behaviour.
    end



  end
end