# encoding: utf-8
require File.join(File.dirname(__FILE__), '/../test_helper')

class RailsCaptureTest < ActionController::TestCase
  context "A Rails controller rendering cells" do
    setup do
      @controller = MusicianController.new
    end
    
    should "see content from global_capture" do
      @controller.class_eval do
        def featured
          render :inline => '<h3><%= @recorded %></h3>' << render_cell(:bassist, :capture)
        end
      end
      
      BassistCell.class_eval do
        helper ::Cells::Helpers::CaptureHelper
        def capture; render; end
      end
      
      get 'featured'
      assert_equal '<h3>DummDoo</h3> DummDoo', @response.body
    end
    
    
    should "see yieldable content from global_content_for" do
      @controller.class_eval do
        def featured
          render :inline => render_cell(:bassist, :content_for) + '<pre><%= yield :recorded %></pre>'
        end
      end
      
      BassistCell.class_eval do
        helper ::Cells::Helpers::CaptureHelper
        def content_for; render; end
      end
       
      get 'featured'
      assert_equal "\n<pre>DummDooDiiDoo</pre>", @response.body
    end
  end
end