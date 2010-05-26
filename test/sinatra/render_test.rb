require File.join(File.dirname(__FILE__), '/../test_helper')
require 'cells/sinatra'
#require File.join(File.dirname(__FILE__), %w(.. app cells singer_cell))

class MyApp < Sinatra::Base
  class << self
    def new(*args, &bk)
      super(*args, &bk).instance_variable_get(:@app)  ### FIXME: how to get a real Sinatra::Base instance?
    end
  end
end

class SinatraRenderTest < ActiveSupport::TestCase
  
  def render_cell(name, state, opts={})  ### FIXME.
      cell = ::Cell::AbstractBase.create_cell_for(@controller, name, opts)
      return cell.render_state(state)
  end
  
  context "Invoking render" do
    setup do
      TestConfiguration.sinatra!
      
      SingerCell.class_eval do
        def solo; @note = "D"; render; end
      end
      
      BackgroundSingerCell.class_eval do
        def sing; render; end # inherits from SingerCell.
      end
      
      @controller = MyApp.new
      
      assert_kind_of Tilt::Cache, @controller.instance_variable_get(:@template_cache)
      assert SingerCell.views.present?
    end
    
    should "render a plain view" do
      SingerCell.class_eval do
        def sing; render; end
      end
      assert_equal "Laaa", render_cell(:singer, :sing)
    end
    
    should "accept the :engine option" do
      SingerCell.class_eval do
        def sing; render :engine => :haml; end
      end
      assert_equal "Haml!\n", render_cell(:singer, :sing)
    end
    
    should "accept the :view option" do
      SingerCell.class_eval do
        def solo; render :view => :sing; end
      end
      assert_equal "Laaa", render_cell(:singer, :solo)
    end
    
    should "raise an error for a non-existent template" do
      SingerCell.class_eval do
        def solo; render :engine => :haml; end
      end
      
      assert_raises Errno::ENOENT do  # from Tilt.
        render_cell(:singer, :solo)
      end
      
      ### TODO: test error message sanity.
    end
    
    should "render instance variables from the cell" do
      assert_equal "Laaalaaa in D", render_cell(:singer, :solo)
    end
    
    # layout
    should "render a view with layout" do
      SingerCell.class_eval do
        def sing; render :layout => :b; end
      end
      assert_equal "<b>Laaa</b>", render_cell(:singer, :sing)
    end
    
    
    # inheriting
    should "inherit sing.html.erb from SingerCell" do
      assert_equal "Laaa", render_cell(:background_singer, :sing)
    end
    
    # named templates
    context "with a named template" do
      setup do
        SingerCell.class_eval do
          template :scream do
            '%h1 AAAaaah'
          end
  
          def sing; haml :scream; end
        end
        
        class HardcoreSingerCell < SingerCell
          template :roar do '%h1 WHOOO' end
          
          def roar; haml :roar; end
        end
      end
      
      should "return a named template" do
        assert_equal "<h1>AAAaaah</h1>\n", render_cell(:singer, :sing)
      end
      
      should "inherit a named template" do
        assert_equal "<h1>AAAaaah</h1>\n", render_cell(:'sinatra_render_test/hardcore_singer', :sing)
      end
      
      should "allow multiple named templates" do
        assert_equal "<h1>WHOOO</h1>\n", render_cell(:'sinatra_render_test/hardcore_singer', :roar)
      end
    end
  end
  
  context "A cell" do
    setup do
      @controller = MyApp.new
    end
    
    # sinatra view api
    should "allow calls to params/response/..." do
      SingerCell.class_eval do
        def pose; render; end
      end
      assert_equal "See me in text/html", render_cell(:singer, :pose)
    end
    
    should "delegate #settings to the app" do
      @controller.class.set :skills, :awesome
      assert_equal :awesome, cell(:singer).settings.skills
    end
  end
  
end