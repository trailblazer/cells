# encoding: utf-8
require File.join(File.dirname(__FILE__), '../test_helper')

class RailsViewTest < ActiveSupport::TestCase
  context "A cell view" do
    context "calling render :partial" do
      should "render the cell partial in bassist/dii" do
        BassistCell.class_eval do
          def compose; @partial = "dii"; render; end
        end
        assert_equal "Dumm Dii", render_cell(:bassist, :compose)
      end
      
      should "render the cell partial in bad_guitarist/dii" do
        BassistCell.class_eval do
          def compose; @partial = "bad_guitarist/dii"; render; end
        end
        assert_equal "Dumm Dooom", render_cell(:bassist, :compose)
      end
    end
  
    
  end
end