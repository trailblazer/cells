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
    it { assert_equal("bassist", ::BassistCell.new(@controller).class.controller_path) }
    it { assert_equal("prefixes_test/singer", SingerCell.new(@controller).class.controller_path) }
  end

  describe "#_prefixes" do
    it { assert_equal( ["test/fixtures/bassist"], ::BassistCell.new(@controller)._prefixes) }
    it { assert_equal(["app/cells/bassist_cell/fender"], ::BassistCell::FenderCell.new(@controller)._prefixes) }
    it { assert_equal(["test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"], ::BassistCell::IbanezCell.new(@controller)._prefixes) }

    it { assert_equal(["app/cells/prefixes_test/singer"], SingerCell.new(@controller)._prefixes) }
    it { assert_equal(["app/cells/prefixes_test/background_vocals", "app/cells/prefixes_test/singer"], BackgroundVocalsCell.new(@controller)._prefixes) }
    it { assert_equal(["app/cells/prefixes_test/chorus", "app/cells/prefixes_test/background_vocals", "app/cells/prefixes_test/singer"], ChorusCell.new(@controller)._prefixes) }

    it { assert_equal(["stringer", "app/cells/prefixes_test/singer"], GuitaristCell.new(@controller)._prefixes) }
    it { assert_equal(["app/cells/prefixes_test/bassist", "basser", "app/cells/prefixes_test/singer"], BassistCell.new(@controller)._prefixes) }

    # multiple view_paths.
    it { assert_equal(["app/cells/engine", "/var/engine/app/cells/engine"], EngineCell.prefixes) }
    it do
      assert_equal([
        "app/cells/inheriting_from_engine", "/var/engine/app/cells/inheriting_from_engine",
        "app/cells/engine",                 "/var/engine/app/cells/engine"],
      InheritingFromEngineCell.prefixes)
    end

    # ::_prefixes is cached.
    it do
      assert_equal(["test/fixtures/wannabe", "test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"], WannabeCell.prefixes)
      WannabeCell.instance_eval { def _local_prefixes; ["more"] end }
      # _prefixes is cached.
      assert_equal(["test/fixtures/wannabe", "test/fixtures/bassist_cell/ibanez", "test/fixtures/bassist"], WannabeCell.prefixes)
      # superclasses don't get disturbed.
      assert_equal(["test/fixtures/bassist"], ::BassistCell.prefixes)
    end
  end
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

  it { assert_equal(["test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"], SlapperCell.new(nil)._prefixes) }
  it { assert_equal(["test/fixtures/inherit_views_test/funker", "test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"], FunkerCell.new(nil)._prefixes) }

  # test if normal cells inherit views.
  it { assert_equal('Doo', cell('inherit_views_test/slapper').play) }
  it { assert_equal('Doo', cell('inherit_views_test/funker').play) }


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
  it { assert_equal('Dooom!', cell('inherit_views_test/tapper').call(:play)) }
  # Tapper renders its tap
  it { assert_equal('Tap tap tap!', cell('inherit_views_test/tapper').call(:tap)) }

  # Popper renders Tapper's play
  it { assert_equal('Dooom!', cell('inherit_views_test/popper').call(:play)) }
  #  Popper renders its tap
  it { assert_equal("TTttttap I'm not good enough!", cell('inherit_views_test/popper').call(:tap)) }
end
