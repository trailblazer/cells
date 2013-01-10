require 'test_helper'

class CellsModuleTest < MiniTest::Spec
  describe "Cells" do
    describe "#view_paths" do
      before do
        @old_view_paths = Cell::Rails.view_paths.clone
      end
      
      after do
        Cell::Rails.view_paths = @old_view_paths
      end
      
      it "provide .before" do
        Cells.setup do |c|
          c.append_view_path "/road/to/nowhere"
        end
        
        if Cell.rails3_2_or_more? or Cell.rails4_0_or_more?
          assert_equal "/road/to/nowhere", Cell::Rails.view_paths.paths.last.to_s
        else
          assert_equal "/road/to/nowhere", Cell::Rails.view_paths.last.to_s
        end
      end
    end
  end
end
