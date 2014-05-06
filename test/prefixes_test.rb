require 'test_helper'


class PrefixesTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  class SingerCell < Cell::Base
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
    it { SingerCell.new(@controller)._prefixes.must_equal   ["prefixes_test/singer"] }
    it { BackgroundVocalsCell.new(@controller)._prefixes.must_equal ["prefixes_test/background_vocals", "prefixes_test/singer"] }
    it { ChorusCell.new(@controller)._prefixes.must_equal   ["prefixes_test/chorus", "prefixes_test/background_vocals", "prefixes_test/singer"] }

    it { GuitaristCell.new(@controller)._prefixes.must_equal ["stringer", "prefixes_test/singer"] }
    it { BassistCell.new(@controller)._prefixes.must_equal ["prefixes_test/bassist", "basser", "prefixes_test/singer"] }
    # it { DrummerCell.new(@controller)._prefixes.must_equal ["drummer", "stringer", "prefixes_test/singer"] }
  end

  # it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }
end