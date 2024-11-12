require 'test_helper'

class PublicTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    def initialize(*args)
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

  class Songs < Cell::Concept
  end

  # ViewModel.cell returns the cell instance.
  it { assert_instance_of SongCell, Cell::ViewModel.cell("public_test/song") }
  it { assert_instance_of SongCell, Cell::ViewModel.cell(PublicTest::SongCell) }

  # Concept.cell simply camelizes the string before constantizing.
  it { assert_instance_of Songs, Cell::Concept.cell("public_test/songs") }
  it { assert_instance_of Songs, Cell::Concept.cell(PublicTest::Songs) }

  # ViewModel.cell passes options to cell.
  it { assert_equal [Object, {genre:"Metal"}], Cell::ViewModel.cell("public_test/song", Object, genre: "Metal").initialize_args }

  # ViewModel.cell(collection: []) renders cells.
  it { assert_equal '[Object, {}][Module, {}]', Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).to_s }

  # DISCUSS: should cell.() be the default?
  # ViewModel.cell(collection: []) renders cells with custom join.
  it do
    Gem::Deprecate::skip_during do
      result = Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).join('<br/>') do |cell|
        cell.()
      end
      assert_equal '[Object, {}]<br/>[Module, {}]', result
    end
  end

  # ViewModel.cell(collection: []) passes generic options to cell.
  it { assert_equal "[Object, {:genre=>\"Metal\", :context=>{:ready=>true}}][Module, {:genre=>\"Metal\", :context=>{:ready=>true}}]", Cell::ViewModel.cell("public_test/song", collection: [Object, Module], genre: 'Metal', context: { ready: true }).to_s }

  # ViewModel.cell(collection: [], method: :detail) invokes #detail instead of #show.
  # TODO: remove in 5.0.
  it do
    Gem::Deprecate::skip_during do
      assert_equal '* [Object, {}]* [Module, {}]', Cell::ViewModel.cell("public_test/song", collection: [Object, Module], method: :detail).to_s
    end
  end

  # ViewModel.cell(collection: []).() invokes #show.
  it { assert_equal '[Object, {}][Module, {}]', Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).() }

  # ViewModel.cell(collection: []).(:detail) invokes #detail instead of #show.
  it { assert_equal '* [Object, {}]* [Module, {}]', Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).(:detail) }

  # #cell(collection: [], genre: "Fusion").() doesn't change options hash.
  it do
    options = { genre: "Fusion", collection: [Object] }
    Cell::ViewModel.cell("public_test/song", options).()
    assert_equal "{:genre=>\"Fusion\", :collection=>[Object]}", options.to_s
  end

  # cell(collection: []).join captures return value and joins it for you.
  it do
    result = Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).join do |cell, i|
      i == 1 ? cell.(:detail) : cell.()
    end
    assert_equal '[Object, {}]* [Module, {}]', result
  end

  # cell(collection: []).join("<") captures return value and joins it for you with join.
  it do
    result = Cell::ViewModel.cell("public_test/song", collection: [Object, Module]).join(">") do |cell, i|
      i == 1 ? cell.(:detail) : cell.()
    end
    assert_equal '[Object, {}]>* [Module, {}]', result
  end

  # 'join' can be used without a block:
  it do
    assert_equal '[Object, {}]---[Module, {}]', Cell::ViewModel.cell(
      "public_test/song", collection: [Object, Module]
    ).join('---')
  end
end
