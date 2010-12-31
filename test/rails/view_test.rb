require 'test_helper'

class RailsViewTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "A cell view" do
    context "calling render :partial" do
      should "render the local cell partial in bassist/dii" do
        assert_equal("Dii", in_view(:bassist) do
          render :partial => 'dii'
        end)
      end
      
      should "render the foreign cell partial in bad_guitarist/dii" do
        assert_equal("Dooom", in_view(:bassist) do
          render :partial => "bad_guitarist/dii"
        end)
      end
    end
    
  end
end
