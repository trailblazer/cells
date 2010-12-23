require 'test_helper'

class CellsModuleTest < ActiveSupport::TestCase
  context "Cells" do
    setup do
      @old_view_paths = Cell::Base.view_paths.clone
    end
    
    should "provide .setup" do
      Cells.setup do |c|
        c.append_view_path "/road/to/nowhere"
      end
      
      assert_equal "/road/to/nowhere", Cell::Base.view_paths.last.to_s
    end
    
    teardown do
      Cell::Base.view_paths = @old_view_paths
    end
  end
end
