require File.join(File.dirname(__FILE__), '/../test_helper')

require 'action_dispatch/routing/route'

class RailsIntegrationTest < ActionController::TestCase
  context "A rails controller" do
    setup do
      ActionDispatch::Routing::Routes.draw { |map| map.connect ':controller/:action/:id' }

      #@routes = Rails::Application.
      @controller = MusicianController.new
    end
    
    should "respond to render_cell" do
      get 'promotion'
      assert_equal "Doo", @response.body
    end
    
    should "respond to render_cell in the view" do
      get 'featured'
      assert_equal "Doo", @response.body
    end
    
  end
  
end