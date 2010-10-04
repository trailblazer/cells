require 'test_helper'

class CellModuleTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "Cell::Base" do
    
    should "provide AbstractBase.render_cell_for" do
      assert_equal "Doo", Cell::Base.render_cell_for(@controller, :bassist, :play)
    end
    
    should "provide possible_paths_for_state" do
      assert_equal ["bad_guitarist/play", "bassist/play", "cell/rails/play"], cell(:bad_guitarist).possible_paths_for_state(:play)
    end
    
    should "provide Cell.cell_name" do
      assert_equal 'bassist', cell(:bassist).class.cell_name
    end
    
    should "provide cell_name for modules, too" do
      class SingerCell < Cell::Base
      end
      
      assert_equal "cell_module_test/singer", CellModuleTest::SingerCell.cell_name
    end
    
    
    should "provide class_from_cell_name" do
      assert_equal BassistCell, ::Cell::Base.class_from_cell_name('bassist')
    end
  end
end
