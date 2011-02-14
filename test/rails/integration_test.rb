require 'test_helper'

class RailsIntegrationTest < ActionController::TestCase
  tests MusicianController
  
  context "A Rails controller" do
    should "respond to #render_cell" do
      get 'promotion'
      assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", @response.body
    end
    
    should "respond to #render_cell with arbitrary options" do
      BassistCell.class_eval do
        def enjoy(what, where="the bar")
          render :text => "I like #{what} in #{where}."
        end
      end
      
      @controller.instance_eval do
        def promotion
          render :text => render_cell(:bassist, :enjoy, "The Stranglers", "my room")
        end
      end
      get 'promotion'
      assert_equal "I like The Stranglers in my room.", @response.body
    end
    
    should "be able to pass a block to #render_cell" do
      get 'promotion_with_block'
      assert_equal "Doo",       @response.body
      assert_equal BassistCell, @controller.flag
    end
    
    should "respond to render_cell in the view without escaping twice" do
      BassistCell.class_eval do
        def provoke; render; end
      end
      get 'featured'
      assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", @response.body
    end
    
    should "respond to render_cell with a block in the view" do
      get 'featured_with_block'
      assert_equal "Doo from BassistCell\n", @response.body
    end
    
    should "respond to render_cell in a haml view" do
      BassistCell.class_eval do
        def provoke; render; end
      end
      get 'hamlet'
      assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />\n", @response.body
    end
    
    should "make params (and friends) available in a cell" do
      BassistCell.class_eval do
        def listen
          render :text => "That's a #{params[:note]}"
        end
      end
      get 'skills', :note => "D"
      assert_equal "That's a D", @response.body
    end
    
    should "respond to #config" do
      BassistCell.class_eval do
        def listen
          render :view => 'contact_form'  # form_tag internally calls config.allow_forgery_protection
        end
      end
      get 'skills'
      assert_equal "<form accept-charset=\"UTF-8\" action=\"musician/index\" method=\"post\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div>\n", @response.body
    end
  end
  
end
