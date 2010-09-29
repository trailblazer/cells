require 'test_helper'

class BaseMethodsTest < ActiveSupport::TestCase
  context "Cell::Base" do
    
    should "provide AbstractBase.render_cell_for" do
      assert_equal "Doo", Cell::Base.render_cell_for(@controller, :bassist, :play)
    end
    
    should "provide possible_paths_for_state" do
      assert_equal ["bad_guitarist/play", "bassist/play", "cell/rails/play"], cell(:bad_guitarist).possible_paths_for_state(:play)
    end
    
    should "provide cell_name" do
      assert_equal 'bassist', cell(:bassist).cell_name
      assert_equal cell(:bassist).cell_name, BassistCell.cell_name
    end
    
    should "provide cell_name for modules, too" do
      class SingerCell
        include Cell::BaseMethods
      end
      
      assert_equal "base_methods_test/singer", BaseMethodsTest::SingerCell.cell_name
    end
    
    
    should "provide class_from_cell_name" do
      assert_equal BassistCell, ::Cell::Base.class_from_cell_name('bassist')
    end
    
    should "provide AbstractBase.default_template_format" do
      cell(:bassist).class.default_template_format = :js
      
      assert_equal :html, ::Cell::Base.default_template_format
      assert_equal :js, cell(:bassist).class.default_template_format
    end
    
  end
end
