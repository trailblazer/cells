require 'test_helper'

class RailsViewTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "A cell view" do
    # DISCUSS: should we allow :partial from a state, too?
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


      should "render the global partial app/views/shared/dong" do
        class PercussionistCell < BassistCell
          append_view_path("test/app/views")
        end
        assert_equal("Dong!", in_view("rails_view_test/percussionist") do
          render :partial => "shared/dong"
        end)
      end
    end
    
    should "respond to render :state" do
      assert_equal("Doo", in_view(:bassist) do
        render :state => :play
      end)
    end
    
    should "respond to render :state with options" do
      BassistCell.class_eval do
        def listen(*args)
          render :text => "Listening to #{args.join(' ')}"
        end
      end
      assert_equal("Listening to Much the Same", in_view(:bassist) do
        render({:state => :listen}, "Much", "the", "Same")
      end)
    end
  end
end
