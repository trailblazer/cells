require File.join(File.dirname(__FILE__), '/../test_helper')

require 'active_support/core_ext/object/to_query'

class RailsIntegrationTest < ActionController::IntegrationTest
  #context "A rails controller" do
    #setup do
    #  @routes = ActionDispatch::Routing::RouteSet.new
    #  @routes.draw { |map| match ':action', :to => ::MusicianController }
      
      #@app = MusicianController.new.to_a
    #end
    
    def app
    self.class
  end
  def self.call(env)
    routes.call(env)
  end
  
  def self.routes
    @routes ||= ActionDispatch::Routing::RouteSet.new
  end

  routes.draw do
    |map| match ':action', :to => ::MusicianController
  end
    
    #include routes.url_helpers
    
    test "respond to render_cell" do
      get 'promotion'
      assert_equal "Doo", @response.body
    end
    
    test "respond to render_cell in the view" do
      get 'featured'
      assert_equal "Doo", @response.body
    end
    
  #end
  
end