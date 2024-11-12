require 'test_helper'

class BassistCell::FenderCell < Cell::ViewModel
end

class BassistCell::IbanezCell < BassistCell
end

class WannabeCell < BassistCell::IbanezCell
end

# engine: shopify
# shopify/cart/cell

class EngineCell < Cell::ViewModel
  self.view_paths << "/var/engine/app/cells"
end
class InheritingFromEngineCell < EngineCell
end

class PrefixesTest < Minitest::Spec
  class SingerCell < Cell::ViewModel
  end

  class BackgroundVocalsCell < SingerCell
  end

  class ChorusCell < BackgroundVocalsCell
  end

  class GuitaristCell < SingerCell
    def self._local_prefixes
      ["stringer"]
    end
  end

  class BassistCell < SingerCell
    def self._local_prefixes
      super + ["basser"]
    end
  end


  describe "::controller_path" do
    it { _(::BassistCell.new(@controller).class.controller_path).must_equal "bassist" }
    it { _(SingerCell.new(@controller).class.controller_path).must_equal "prefixes_test/singer" }
  end

  describe "#_prefixes" do
    it { _(::BassistCell.new(@controller)._prefixes).must_equal  ["test/fixtures/bassist"] }
    it { _(::BassistCell::FenderCell.new(@controller)._prefixes).must_equal ["app/cells/bassist_cell/fender"] }
    it { _(::BassistCell::IbanezCell.new(@controller)._prefixes).must_equal ["test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"] }

    it { _(SingerCell.new(@controller)._prefixes).must_equal   ["app/cells/prefixes_test/singer"] }
    it { _(BackgroundVocalsCell.new(@controller)._prefixes).must_equal ["app/cells/prefixes_test/background_vocals", "app/cells/prefixes_test/singer"] }
    it { _(ChorusCell.new(@controller)._prefixes).must_equal   ["app/cells/prefixes_test/chorus", "app/cells/prefixes_test/background_vocals", "app/cells/prefixes_test/singer"] }

    it { _(GuitaristCell.new(@controller)._prefixes).must_equal ["stringer", "app/cells/prefixes_test/singer"] }
    it { _(BassistCell.new(@controller)._prefixes).must_equal ["app/cells/prefixes_test/bassist", "basser", "app/cells/prefixes_test/singer"] }
    # it { DrummerCell.new(@controller)._prefixes.must_equal ["drummer", "stringer", "prefixes_test/singer"] }

    # multiple view_paths.
    it { _(EngineCell.prefixes).must_equal ["app/cells/engine", "/var/engine/app/cells/engine"] }
    it do
      _(InheritingFromEngineCell.prefixes).must_equal [
        "app/cells/inheriting_from_engine", "/var/engine/app/cells/inheriting_from_engine",
        "app/cells/engine",                 "/var/engine/app/cells/engine"]
    end

    # ::_prefixes is cached.
    it do
      _(WannabeCell.prefixes).must_equal ["test/fixtures/wannabe", "test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"]
      WannabeCell.instance_eval { def _local_prefixes; ["more"] end }
      # _prefixes is cached.
      _(WannabeCell.prefixes).must_equal ["test/fixtures/wannabe", "test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"]
      # superclasses don't get disturbed.
      _(::BassistCell.prefixes).must_equal ["test/fixtures/bassist"]
    end
  end

  # it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }
end

class InheritViewsTest < Minitest::Spec
  class SlapperCell < Cell::ViewModel
    self.view_paths = ['test/fixtures'] # todo: REMOVE!
    include Cell::Erb

    inherit_views ::BassistCell

    def play
      render
    end
  end

  class FunkerCell < SlapperCell
  end

  it { _(SlapperCell.new(nil)._prefixes).must_equal ["test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"] }
  it { _(FunkerCell.new(nil)._prefixes).must_equal ["test/fixtures/inherit_views_test/funker", "test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"] }

  # test if normal cells inherit views.
  it { _(cell('inherit_views_test/slapper').play).must_equal 'Doo' }
  it { _(cell('inherit_views_test/funker').play).must_equal 'Doo' }


  # TapperCell
  class TapperCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']
    # include Cell::Erb

    def play
      render
    end

    def tap
      render
    end
  end

  class PopperCell < TapperCell
  end

  # Tapper renders its play
  it { _(cell('inherit_views_test/tapper').call(:play)).must_equal 'Dooom!' }
  # Tapper renders its tap
  it { _(cell('inherit_views_test/tapper').call(:tap)).must_equal 'Tap tap tap!' }

  # Popper renders Tapper's play
  it { _(cell('inherit_views_test/popper').call(:play)).must_equal 'Dooom!' }
  #  Popper renders its tap
  it { _(cell('inherit_views_test/popper').call(:tap)).must_equal "TTttttap I'm not good enough!" }
end
