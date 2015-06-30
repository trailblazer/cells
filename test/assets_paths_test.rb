require "test_helper"

class AssetsPathsTest < MiniTest::Spec
  Hit = Struct.new(:title)

  class Song::Cell < Cell::Concept
    self.view_paths = ["test/fixtures"]
  end

  class Album::Cell < Cell::Concept
    self.view_paths = ["test/fixtures"]
    self.assets_paths = ["assets"]
  end

  class Hit::Cell < Cell::Concept
    self.assets_paths << "assets"
  end

  class Top10Cell < Cell::ViewModel
  end

  class Top100Cell < Cell::ViewModel
    self.assets_paths = ["assets"]
  end

  describe "#_assets_prefixes" do
    # app/cells/name/
    it { Top10Cell.new(@controller)._assets_prefixes.must_equal ["app/cells/assets_paths_test/top10"] }

    # app/cells/name/assets
    it { Top100Cell.new(@controller)._assets_prefixes.must_equal ["app/cells/assets_paths_test/top100/assets"] }

    # app/concepts/name/views
    it { Song::Cell.new(@controller)._assets_prefixes.must_equal ["test/fixtures/song/views"] }

    # app/concepts/name/assets
    it { Album::Cell.new(@controller)._assets_prefixes.must_equal ["test/fixtures/album/assets"] }

    # app/concepts/name/assets, app/concepts/name/views
    it do
      Hit::Cell.new(@controller)._assets_prefixes.must_equal [
        "test/fixtures/concepts/assets_paths_test/hit/views",
        "test/fixtures/concepts/assets_paths_test/hit/assets"
      ]
    end
  end
end
