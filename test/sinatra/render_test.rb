require File.join(File.dirname(__FILE__), '/../test_helper')



require 'cells/sinatra'  ### FIXME.

class MyApp < Sinatra::Base
  class << self
    def new(*args, &bk)
      super(*args, &bk).instance_variable_get(:@app)  ### FIXME: how to get a real Sinatra::Base instance?
    end
  end
end


class SinatraRenderTest < ActiveSupport::TestCase
  
  def render_cell(name, state, opts={})  ### FIXME.
      cell = ::Cell::Base.create_cell_for(@controller, name, opts)
      return cell.render_state(state)
  end
  
  context "Invoking render" do
    setup do
      Cell::Base.framework = :sinatra
      
      BassistCell.class_eval do
        def slap; @note = "D"; render; end
      end
      
      BadGuitaristCell.class_eval do
        def play; render; end # inherits from BassistCell.
      end
      
      @controller = MyApp.new
      
      assert_kind_of Tilt::Cache, @controller.instance_variable_get(:@template_cache)
    end
    
    should "render a plain view" do
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "render a haml view" do
      BassistCell.class_eval do
        def sing; render :engine => :haml; end
      end
      assert_equal "Haml!\n", render_cell(:bassist, :sing)
    end
    
    should "raise an error for an non-existent template" do
      
    end
    
    should "render instance variables from the cell" do
      assert_equal "Boing in D", render_cell(:bassist, :slap)
    end
    
    # layout
    should "render a view with layout" do
      BassistCell.class_eval do
        def play; render :layout => :b; end
      end
      assert_equal "<b>Doo</b>", render_cell(:bassist, :play)
    end
    
    
    # inheriting
    should "inherit play.html.erb from BassistCell" do
      assert_equal "Doo", render_cell(:bad_guitarist, :play)
    end
  end
  
  context "A cell" do
    setup do
      @controller = MyApp.new
      
      Cell::Base.framework = :sinatra
    end
    
    # sinatra view api
    should "allow calls to params/response/..." do
      BassistCell.class_eval do
        def pose; render; end
      end
      assert_equal "See me in text/html", render_cell(:bassist, :pose)
    end
    
    should "delegate #settings to the app" do
      @controller.class.set :skills, :awesome
      assert_equal :awesome, cell(:bassist).settings.skills
    end
  end
  
end