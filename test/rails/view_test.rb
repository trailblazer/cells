require 'test_helper'

class RailsViewTest < MiniTest::Spec
  include Cell::TestCase::TestMethods
  
  describe "A cell view" do
    # DISCUSS: it we allow :partial from a state, too?
    describe "calling render :partial" do
      it "render the local cell partial in bassist/dii" do
        assert_equal("Dii", in_view(:bassist) do
          render :partial => 'dii'
        end)
      end
      
      it "render the foreign cell partial in bad_guitarist/dii" do
        assert_equal("Dooom", in_view(:bassist) do
          render :partial => "bad_guitarist/dii"
        end)
      end


      it "render the global partial app/views/shared/dong" do
        class PercussionistCell < BassistCell
          append_view_path("test/app/views")
        end
        assert_equal("Dong!", in_view("rails_view_test/percussionist") do
          render :partial => "shared/dong"
        end)
      end
    end
    
    it "respond to render :state" do
      assert_equal("Doo", in_view(:bassist) do
        render :state => :play
      end)
    end
    
    it "respond to render :state with options" do
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
