require_relative 'helper'

class PublicTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    def initialize(controller, *args)
      @parent_controller = controller # TODO: this is removed in 4.0.
      @initialize_args = *args
    end
    attr_reader :initialize_args

    def show
      initialize_args.inspect
    end

    def detail
      "* #{initialize_args}"
    end
  end

  # ViewModel.cell returns the cell instance.
  it { Cell::ViewModel.cell("public_test/song", nil).must_be_instance_of SongCell }

  # ViewModel.cell passes options to cell.
  it { Cell::ViewModel.cell("public_test/song", nil, Object, genre: "Metal").initialize_args.must_equal [Object, {:genre=>"Metal"}] }

  # ViewModel.cell(collection: []) renders cells.
  it { Cell::ViewModel.cell("public_test/song", nil, collection: [Object, Module]).must_equal "[Object, {}]\n[Module, {}]" }

  # ViewModel.cell(collection: []) renders html_safe.
  it { Cell::ViewModel.cell("public_test/song", nil, collection: [Object]).class.must_equal ActiveSupport::SafeBuffer }

  # ViewModel.cell(collection: []) passes generic options to cell.
  it { Cell::ViewModel.cell("public_test/song", nil, collection: [Object, Module], genre: "Metal").must_equal "[Object, {:genre=>\"Metal\"}]\n[Module, {:genre=>\"Metal\"}]" }

  # ViewModel.cell(collection: [], method: :detail) invokes #detail instead of #show.
  it { Cell::ViewModel.cell("public_test/song", nil, collection: [Object, Module], method: :detail).must_equal "* [Object, {}]\n* [Module, {}]" }
end

# TODO: test AV::concept.