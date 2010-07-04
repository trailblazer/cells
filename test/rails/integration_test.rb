require File.join(File.dirname(__FILE__), '/../test_helper')

require 'active_support/core_ext/object/to_query'

class RailsIntegrationTest < ActionController::TestCase
  
  context "A Rails controller" do
    setup do
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        |map| match ':action', :to => MusicianController
      end
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
    
    should "make params (and friends) available in a cell" do
      BassistCell.class_eval do
        def listen
          render :text => "That's a #{params[:note]}"
        end
      end
      puts "riptide"
      get 'skills', :note => "D"
      assert_equal "That's a D", @response.body
    end
  end
  
end