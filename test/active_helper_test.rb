require 'test_helper'

### DISCUSS: how can we limit that test to systems where ActiveHelper's around?

class ActiveHelperTest < ActiveSupport::TestCase
  context "The Cell::Base class" do
    setup do
      class FingeringHelper < ActiveHelper::Base
        provides :finger
      end
      
      class SlappingHelper < ActiveHelper::Base
        provides :slap
      end
    end
    
    should_eventually "respond to active_helper" do
      assert_respond_to Cell::Base, :active_helper
    end
    
    should_eventually "store helper constants from active_helper" do
      @cell = Class.new(BassistCell)
      @cell.active_helper SlappingHelper
      assert_equal [SlappingHelper], @cell.active_helpers
    end
    
    should_eventually "inherit helper constants from active_helper" do
      @base_cell = Class.new(BassistCell)
      @base_cell.active_helper SlappingHelper
      @cell = Class.new(@base_cell)
      @cell.active_helper FingeringHelper
      assert_equal [SlappingHelper, FingeringHelper], @cell.active_helpers
    end
    
    
    context "An Cell::View::Base instance" do
      should_eventually "respond to use" do
        # we didn't extend the view at this point.
        @view = bassist_mock.setup_action_view
        assert_respond_to @view, :use
      end
      
    end
    
    context "The view rendered by the cell" do
      should_eventually "respond to used helper methods" do
        @cell = bassist_mock
        @cell.class.active_helper SlappingHelper
        
        @view = @cell.setup_action_view
        @cell.prepare_action_view_for(@view, {})
        
        assert_respond_to @view, :slap # from the SlappingHelper
      end
    end
  end
end
