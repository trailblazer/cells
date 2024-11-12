require 'test_helper'

class CellTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

    def show
    end

    def show_with_block(&block)
      render(&block)
    end
  end

  # #options
  it { _(SongCell.new(nil, genre: "Punkrock").send(:options)[:genre]).must_equal "Punkrock" }

  # #block
  it { _(SongCell.new(nil, genre: "Punkrock").(:show_with_block) { "hello" }).must_equal "<b>hello</b>\n" }
end
