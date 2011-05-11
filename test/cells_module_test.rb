require 'test_helper'

class CellsModuleTest < ActiveSupport::TestCase
  context "Cells" do
    context "view_paths" do
      setup do
        @old_view_paths = Cell::Base.view_paths.clone
      end
      
      teardown do
        Cell::Base.view_paths = @old_view_paths
      end
      
      should "provide .setup" do
        Cells.setup do |c|
          c.append_view_path "/road/to/nowhere"
        end
        
        assert_equal "/road/to/nowhere", Cell::Base.view_paths.last.to_s
      end
    end
    
    should "respond to #rails3_1?" do
      if Rails::VERSION::MINOR == 0
        assert ! Cells.rails3_1?
        assert Cells.rails3_0?
      elsif
        assert Cells.rails3_1?
        assert ! Cells.rails3_0?
      end
    end
  end
end
