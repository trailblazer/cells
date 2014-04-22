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
    # prefix: record/
    #         record/views/
    def show
      render
    end

    def controller_path
      # TODO: cache on class level
      # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
      # applies to Comment::Cell, Comment::Cell::Form, etc.
      self.class.name.sub(/::Cell/, '').underscore # unless anonymous?
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
    # prefix: record/song/
    #         record/song/views/
    #         record/
    #         record/views/
    end
  end

  # class SongCell < Cell::Rails
  #   inherit_views Record::Cell # we don't want real inheritance.
  # end
end


class TrailblazerTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

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


    describe "#controller_path" do
      it { Record::Cell.new(@controller).controller_path.must_equal "record" }
      it { Record::Cell::Song.new(@controller).controller_path.must_equal "record/song" }
    end

    it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }


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


    class BandCell < Cell::Rails
      self_contained!
      class SongCell < self
      end
    end

    describe "#_prefixes with self_contained!" do
      it { cell("trailblazer_test/band")._prefixes.must_equal(["trailblazer_test/band/views"]) }
      it { cell("trailblazer_test/band_cell/song")._prefixes.must_equal(["trailblazer_test/band_cell/song/views", "trailblazer_test/band/views"]) } # this is semi-cool, but the old behaviour.
    end
  end
end