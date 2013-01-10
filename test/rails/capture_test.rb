require 'test_helper'

class ProducerCell < Cell::Rails
  #helper ::Cells::Helpers::CaptureHelper
  
end

class RailsCaptureTest < ActionController::TestCase
  tests MusicianController

  test "#content_for" do
    @controller.class_eval do
      def featured
        
        render :inline => '<%= render_cell(:producer, :content_for, self) %><pre><%= yield :recorded %></pre>'
      end
    end
    
    ProducerCell.class_eval do
      def content_for(tpl); 
puts tpl
@tpl = tpl

        render; end

      def global_content_for(*args, &block)
        @tpl.content_for(*args, &block)
      end
      helper_method :global_content_for
    end
     
    get 'featured'
    assert_equal "\n<pre>DummDooDiiDoo</pre>", @response.body
  end


  describe "what" do
    it "see content from global_capture" do
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
    
    
    it "see yieldable content from global_content_for" do
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
