require 'test_helper'

class CellTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

    def show
    end

    def show_with_block(&block)
      render(&block)
    end

    def show_inception
      render
    end
  end

  # #options
  it { SongCell.new(nil, genre: "Punkrock").send(:options)[:genre].must_equal "Punkrock" }

  # #block
  it { SongCell.new(nil, genre: "Punkrock").(:show_with_block) { "hello" }.must_equal "<b>hello</b>\n" }

  # #block inside a block (inception!)
  it { SongCell.new(nil, genre: "Punkrock").(:show_inception).must_equal "<b>inside the b tag</b>\n" }
end
