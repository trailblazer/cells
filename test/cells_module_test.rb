require 'test_helper'

class CellsModuleTest < ActiveSupport::TestCase
  context "Cells" do
    context "view_paths" do
      setup do
        @old_view_paths = Cell::Rails.view_paths.clone
      end
      
      teardown do
        Cell::Rails.view_paths = @old_view_paths
      end
      
      should "provide .setup" do
        Cells.setup do |c|
          c.append_view_path "/road/to/nowhere"
        end
        
        if Cells.rails3_2_or_more?
          assert_equal "/road/to/nowhere", Cell::Rails.view_paths.paths.last.to_s
        else
          assert_equal "/road/to/nowhere", Cell::Rails.view_paths.last.to_s
        end
      end
    end
    
    should "respond to #rails3_1_or_more?" do
      if Rails::VERSION::MINOR == 0
        assert ! Cells.rails3_1_or_more?
        assert Cells.rails3_0?
      elsif Rails::VERSION::MINOR == 1
        assert Cells.rails3_1_or_more?
        assert ! Cells.rails3_0?
      elsif Rails::VERSION::MINOR == 2
        assert Cells.rails3_1_or_more?
        assert ! Cells.rails3_0?
      end
    end
  end
end
