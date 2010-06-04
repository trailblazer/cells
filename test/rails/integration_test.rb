require File.join(File.dirname(__FILE__), '/../test_helper')

class RailsIntegrationTest < ActionController::TestCase
  context "A rails controller" do
    setup do
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