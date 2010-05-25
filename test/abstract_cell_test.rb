require File.join(File.dirname(__FILE__), 'test_helper')

class AbstractCellTest < ActiveSupport::TestCase
  context "Cell::Base" do
    
    should "provide render_cell_for" do
      assert_equal "Doo", Cell::AbstractBase.render_cell_for(@controller, :bassist, :play)
    end
  end
end