require File.join(File.dirname(__FILE__), '/../test_helper')
#RAILS_ROOT = File.dirname(__FILE__)
class RailsRenderTest < ActiveSupport::TestCase
  context "Invoking render" do
    should "render a plain view" do
      BassistCell.class_eval do
        def play; render; end
      end
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "also render alternative engines" do
      BassistCell.class_eval do
        def sing; @xm = Builder::XmlMarkup.new; render; end
      end
      assert_equal "", render_cell(:bassist, :sing) ### FIXME: where's the rendered xml?
    end
    
    should "accept the :template_format option" do
      
    end
    
    should "accept the :nothing option" do
      BassistCell.class_eval do
        def sleep; render :nothing => true; end
      end
      assert_equal "", render_cell(:bassist, :sleep)
    end
    
    
    should "accept the :view option" do
      BassistCell.class_eval do
        def solo; render :view => :play; end
      end
      assert_equal "Doo", render_cell(:bassist, :solo)
    end
    
    should "accept the :text options" do
      BassistCell.class_eval do
        def sing; render :text => "Shoobie"; end
      end
      assert_equal "Shoobie", render_cell(:bassist, :sing)
    end
    
    should "accept the :inline option" do
      BassistCell.class_eval do
        def sleep; render :inline => "<%= 'Snooore' %>"; end
      end
      assert_equal "Snooore", render_cell(:bassist, :sleep)
    end
    
    should "accept the :state option" do
      BassistCell.class_eval do
        def play; render; end
        def groove; render :state => :play; end
      end
      assert_equal "Doo", render_cell(:bassist, :groove)
    end
    
    should "accept the :locals option" do
      BassistCell.class_eval do
        def ahem; render :locals => {:times => 2}; end
      end
      assert_equal "AhemAhem", render_cell(:bassist, :ahem)
    end
    
    
    # layout
    should "accept the :layout option" do
      BassistCell.class_eval do
        def play; render :layout => 'b'; end
      end
      assert_equal "<b>Doo</b>", render_cell(:bassist, :play)
    end
    
    should "raise an error for a non-existent template" do
      BassistCell.class_eval do
        def groove; render; end
      end
      
      assert_raises ActionView::MissingTemplate do
        render_cell(:bassist, :groove)
      end
      
      ### TODO: test error message sanity.
    end
    
    should "render instance variables from the cell" do
      BassistCell.class_eval do
        def slap
          @note = "D"; render
        end
      end
      assert_equal "Boing in D", render_cell(:bassist, :slap)
    end
    
    should "allow subsequent calls to render in the rendered view" do
      BassistCell.class_eval do
        def jam; @chords = [:a, :c]; render; end
        def play; render; end
      end
      assert_equal "\nDoo\n\nDoo\n", render_cell(:bassist, :jam)
    end
    
    should "allow multiple calls to render" do
      BassistCell.class_eval do
        def play; render + render + render; end
      end
      assert_equal "DooDooDoo", render_cell(:bassist, :play)
    end
    
    
    
    
    # inheriting
    should "inherit play.html.erb from BassistCell" do
      assert_equal "Doo", render_cell(:bad_guitarist, :play)
    end
  end
  
  context "A cell view" do
    # rails view api
    should "allow calls to params/response/..." do
      BassistCell.class_eval do
        def pose; render; end
      end
      assert_equal "Come and get me!", render_cell(:bassist, :pose)
    end
    
    
  end
  
end