require 'test_helper'

class I18nConcept
  class Testing < Cell::ViewModel
    include Cell::I18n
  end
end

class NoModuleCell < Cell::ViewModel
  include Cell::I18n
end

class CellI18nUnitTest < MiniTest::Spec
  describe '#i18n_scoped_path' do
    let(:i18n_cell) { I18nConcept::Testing.new }
    let(:no_module_cell) { NoModuleCell.new }

    it 'handles no module cells and returns a scoped key if the key starts with .' do
      no_module_cell.i18n_scoped_path('.test').must_equal 'cells.no_module_cell.test'
    end

    it 'returns a scoped key if the key starts with .' do
      i18n_cell.i18n_scoped_path('.test').must_equal 'cells.i18n_concept.testing.test'
    end

    it 'returns a non-scoped key' do
      i18n_cell.i18n_scoped_path('test.test').must_equal 'test.test'
    end
  end
end
