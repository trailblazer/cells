require 'test_helper'

class OptionsTest < MiniTest::Spec
  Song = Struct.new(:title)
  Hit  = Struct.new(:title)

  class CellWithOptions < Cell::ViewModel
    option :non_required
    option :required, required: true
    option :has_default, default: 'hola'

    def show
      [non_required, required, has_default].join('-')
    end

    def show_non_required
      non_required
    end

    def show_required
      required
    end

    def show_has_default
      has_default
    end
  end

  # basic usage
  it do
    cell = CellWithOptions.(nil, non_required: 'a', required: 'b', has_default: 'c')
    cell.show_non_required.must_equal 'a'
    cell.show_required.must_equal 'b'
    cell.show_has_default.must_equal 'c'
  end

  # missing required option
  it do
    assert_raises Cell::MissingOptionError do
      CellWithOptions.(nil, non_required: 'a', has_default: 'b')
    end
  end

  # non-required options with and without default
  it do
    cell = CellWithOptions.(nil, required: 'a')
    assert_nil cell.show_non_required
    cell.show_has_default.must_equal 'hola'
  end

  # collection
  it do
    # with missing required option:
    assert_raises Cell::MissingOptionError do
      CellWithOptions.(collection: [1, 2]).()
    end

    cells = CellWithOptions.(collection: [1, 2], non_required: 'a', required: 'b', has_default: 'c')
    cells.join(' ').to_s.must_equal('a-b-c a-b-c')
  end
end
