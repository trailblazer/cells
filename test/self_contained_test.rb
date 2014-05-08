require 'test_helper'

class AlbumCell < Cell::Rails
  self_contained!

  def cover
    @title = "The Sufferer & The Witness"
    render
  end

  class SongCell < self
  end
end

unless Cell.rails_version.~("3.0")

  class SelfContainedTest < MiniTest::Spec
    include Cell::TestCase::TestMethods

    let (:album) { cell(:album) }

    it "renders views from album/views/" do
     album.render_state(:cover).must_equal "<h3>The Sufferer &amp; The Witness</h3>\n"
    end

    describe "#_prefixes" do
      it { cell("album")._prefixes.must_equal(["album/views"]) }
      it { cell("album_cell/song")._prefixes.must_equal(["album_cell/song/views", "album/views"]) } # this is semi-cool, but the old behaviour.
    end
  end
end