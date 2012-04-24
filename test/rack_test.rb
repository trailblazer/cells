require 'test_helper'

class RackTest < MiniTest::Spec
  class BassistCell < Cell::Rack
    def play
      render :text => request.class
    end
    
    def sing
      render :text => session[:what]
    end
  end
  
  describe "Cell::Rack" do
    before do
      @request = ActionDispatch::TestRequest.new
    end
    
    it "allows accessing the request object" do
      assert_equal "ActionDispatch::TestRequest", BassistCell.new(@request).render_state(:play)
    end
    
    it "allows accessing the session object" do
      @request.session[:what] = "Yo!"
      assert_equal "Yo!", BassistCell.new(@request).render_state(:sing)
    end
    
    it "works with #render_cell_for" do
      assert_equal "ActionDispatch::TestRequest", Cell::Rack.render_cell_for("rack_test/bassist", :play, @request)
    end
  end
end
