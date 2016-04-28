require 'test_helper'

class CellTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

    def show
    end

    def show_with_block(&block)
      render do
        block
      end
    end
  end
  # ::rails_version
  it { Cell.rails_version.must_equal Gem::Version.new(ActionPack::VERSION::STRING) }

  # #options
  it { SongCell.new(nil, genre: "Punkrock").send(:options)[:genre].must_equal "Punkrock" }

  # #block
  it { SongCell.new(nil, genre: "Punkrock").(:show_with_block) { "hello" }.must_equal "<b>hello</b>" }
end
