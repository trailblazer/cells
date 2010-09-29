require 'test_helper'

class ProducerCell < Cell::Base
  helper ::Cells::Helpers::CaptureHelper
  
  def logger(*args); puts args.inspect; end
end

class RailsCaptureTest < ActionController::TestCase
  context "A Rails controller rendering cells" do
    setup do
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        |map| match ':action', :to => MusicianController
      end
      @controller = MusicianController.new
    end
    
    should "see content from global_capture" do
      @controller.class_eval do
        def featured
          render :inline => '<h3><%= @recorded %></h3>' << render_cell(:producer, :capture)
        end
      end
      
      ProducerCell.class_eval do
        def capture; render; end
      end
      
      get 'featured'
      assert_equal '<h3>DummDoo</h3> DummDoo', @response.body
    end
    
    
    should "see yieldable content from global_content_for" do
      @controller.class_eval do
        def featured
          render_cell(:producer, :content_for)
          render :inline => '<pre><%= yield :recorded %></pre>'
        end
      end
      
      ProducerCell.class_eval do
        def content_for; render; end
      end
       
      get 'featured'
      assert_equal "\n<pre>DummDooDiiDoo</pre>", @response.body
    end
  end
end
