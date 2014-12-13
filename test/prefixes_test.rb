require 'test_helper'

class BassistCell::FenderCell < Cell::ViewModel
end

class BassistCell::IbanezCell < BassistCell
end

class PrefixesTest < MiniTest::Spec
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
    it { ::BassistCell.new(@controller).controller_path.must_equal "bassist" }
    it { SingerCell.new(@controller).controller_path.must_equal "prefixes_test/singer" }
  end

  describe "#_prefixes" do
    it { ::BassistCell.new(@controller)._prefixes.must_equal  ["bassist"] }
    it { ::BassistCell::FenderCell.new(@controller)._prefixes.must_equal ["bassist_cell/fender"] }
    it { ::BassistCell::IbanezCell.new(@controller)._prefixes.must_equal ["bassist_cell/ibanez", "bassist"] }

    it { SingerCell.new(@controller)._prefixes.must_equal   ["prefixes_test/singer"] }
    it { BackgroundVocalsCell.new(@controller)._prefixes.must_equal ["prefixes_test/background_vocals", "prefixes_test/singer"] }
    it { ChorusCell.new(@controller)._prefixes.must_equal   ["prefixes_test/chorus", "prefixes_test/background_vocals", "prefixes_test/singer"] }

    it { GuitaristCell.new(@controller)._prefixes.must_equal ["stringer", "prefixes_test/singer"] }
    it { BassistCell.new(@controller)._prefixes.must_equal ["prefixes_test/bassist", "basser", "prefixes_test/singer"] }
    # it { DrummerCell.new(@controller)._prefixes.must_equal ["drummer", "stringer", "prefixes_test/singer"] }
  end

  # it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }
end

class InheritViewsTest < MiniTest::Spec
  class SlapperCell < Cell::ViewModel
    self.view_paths = ['test/fixtures'] # todo: REMOVE!

    inherit_views ::BassistCell

    def play
      render
    end
  end

  class FunkerCell < SlapperCell
  end

  it { SlapperCell.new(nil)._prefixes.must_equal ["inherit_views_test/slapper", "bassist"] }
  it { FunkerCell.new(nil)._prefixes.must_equal ["inherit_views_test/funker", "inherit_views_test/slapper", "bassist"] }

  # test if normal cells inherit views.
  it { cell('inherit_views_test/slapper').play.must_equal 'Doo' }
  it { cell('inherit_views_test/funker').play.must_equal 'Doo' }


  # TapperCell
  class TapperCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

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
  it { cell('inherit_views_test/tapper').call(:play).must_equal 'Dooom!' }
  # Tapper renders its tap
  it { cell('inherit_views_test/tapper').call(:tap).must_equal 'Tap tap tap!' }

  # Popper renders Tapper's play
  it { cell('inherit_views_test/popper').call(:play).must_equal 'Dooom!' }
  #  Popper renders its tap
  it { cell('inherit_views_test/popper').call(:tap).must_equal "TTttttap I'm not good enough!" }
end