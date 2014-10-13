require_relative 'helper'

class CellTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    def show
    end
  end
  # ::rails_version
  it { Cell.rails_version.must_equal Gem::Version.new(ActionPack::VERSION::STRING) }

  # #options
  it { SongCell.new(nil, nil, genre: "Punkrock").send(:options)[:genre].must_equal "Punkrock" }
end
