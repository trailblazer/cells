require 'test_helper'

class RailsRenderTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "Invoking render" do
    
    should "render a plain view" do
      BassistCell.class_eval do
        def play; render; end
      end
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "also render alternative engines, like haml" do
      BassistCell.class_eval do
        def sing; render; end
      end
      assert_equal "<h1>Laaa</h1>\n", render_cell(:bassist, :sing)
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
      assert render_cell(:bassist, :sing).html_safe?
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
    end
    
    should "raise an error for a non-existent template" do
      BadGuitaristCell.class_eval do
        def groove; render; end
      end
      
      e = assert_raise Cell::Rails::MissingTemplate do
        render_cell(:bad_guitarist, :groove)
      end
      
      assert_equal "Missing template cell/rails/groove with {:handlers=>[:erb, :rjs, :builder, :rhtml, :rxml, :haml], :formats=>[:html, :text, :js, :css, :ics, :csv, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json], :locale=>[:en, :en]} in view paths \"/home/nick/projects/cells/app/cells\", \"/home/nick/projects/cells/app/cells/layouts\", \"/home/nick/projects/cells/test/app/cells\", \"/home/nick/projects/cells/test/app/cells/layouts\" and possible paths [\"bad_guitarist/groove\", \"bassist/groove\", \"cell/rails/groove\"]", e.message
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
        def sing; render; end
      end
      assert_equal "<h1>Laaa</h1>\n\n<h1>Laaa</h1>\n\n", render_cell(:bassist, :jam)
    end
    
    should "allow multiple calls to render" do
      BassistCell.class_eval do
        def sing; render + render + render; end
      end
      assert_equal "<h1>Laaa</h1>\n<h1>Laaa</h1>\n<h1>Laaa</h1>\n", render_cell(:bassist, :sing)
    end
    
    # inheriting
    should "inherit play.html.erb from BassistCell" do
      BassistCell.class_eval do
        def play; render; end
      end
      assert_equal "Doo", render_cell(:bad_guitarist, :play)
    end
  end
  
  context "A cell view" do
    # rails view api
    should "allow calls to params/response/..." do
      BassistCell.class_eval do
        def pose; render; end
      end
      
      @request.env["action_dispatch.request.request_parameters"] = {:what => 'get'}
      @cell = cell(:bassist)
      
      assert_equal "Come and get me!", @cell.render_state(:pose)
    end
    
    
  end
end
