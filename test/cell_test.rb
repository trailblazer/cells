require 'test_helper'

class CellTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    def show
    end
  end

  # #options
  it { SongCell.new(nil, genre: "Punkrock").send(:options)[:genre].must_equal "Punkrock" }
end
