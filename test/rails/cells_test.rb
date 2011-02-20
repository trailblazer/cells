require 'test_helper'

class RailsCellsTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end
  
  context "#render_state" do
    should "work without args" do
      BassistCell.class_eval do
        def listen
          render :text => options[:note]
        end
      end
      assert_equal "D", cell(:bassist, :note => "D").render_state(:listen)
    end
    
    should "accept state-args" do
      BassistCell.class_eval do
        def listen(args)
          render :text => args[:note]
        end
      end
      assert_equal "D", cell(:bassist).render_state(:listen, :note => "D")
    end
    
    should "accept state-args with default parameters" do
      BassistCell.class_eval do
        def listen(first, second="D")
          render :text => first+second
        end
      end
      assert_equal "AD", cell(:bassist).render_state(:listen, "A")
    end
  end
  
  
  context "A rails cell" do
    should "respond to DEFAULT_VIEW_PATHS" do
      assert_equal ["app/cells", "app/cells/layouts"], Cell::Base::DEFAULT_VIEW_PATHS
    end
    
    should "respond to .setup_view_paths!" do
      swap( Cell::Base, :view_paths => [])  do
        Cell::Base.setup_view_paths!
        assert_equal ActionView::PathSet.new(Cell::Rails::DEFAULT_VIEW_PATHS), Cell::Base.view_paths
      end
    end
    
    should "respond to view_paths" do
      assert_kind_of ActionView::PathSet, Cell::Rails.view_paths, "must be a PathSet for proper template caching/reloading (see issue#2)"
    end
    
    should "respond to view_paths=" do
      swap( Cell::Base, :view_paths => ['you', 'are', 'here'])  do
        assert_kind_of ActionView::PathSet, Cell::Base.view_paths, "must not wipe out the PathSet"
      end
    end
    
    should "respond to #request" do
      assert_equal @request, cell(:bassist).request
    end
    
    should "respond to #config" do
      assert_equal({}, cell(:bassist).config)
    end
    
    include ActiveSupport::Testing::Deprecation
    should "mark @opts as deprecated, but still works" do
      res = nil
      assert_deprecated do
        res = cell(:bassist, :song => "Lockdown").instance_eval do
          @opts[:song]
        end
      end
      assert_equal "Lockdown", res
    end
    
    should "respond to #options and return the cell options" do
      assert_equal({:song => "Lockdown"}, cell(:bassist, :song => "Lockdown").options)
    end
    
    context "invoking defaultize_render_options_for" do
      should "set default values" do
        options = cell(:bassist).send(:defaultize_render_options_for, {}, :play)
        
        assert_equal :play, options[:view]
      end
      
      should "allow overriding defaults" do
        assert cell(:bassist).send(:defaultize_render_options_for, {:view => :slap}, :play)[:view] == :slap
      end
    end
    
    context "invoking find_family_view_for_state" do
      should "raise an error when a template is missing" do
        assert_raises ActionView::MissingTemplate do
          cell(:bassist).find_template("bassist/playyy")
        end
        
        puts "format: #{cell(:bassist).find_template("bassist/play.js").formats.inspect}"
      end
      
      should "return play.html.erb" do
        assert_equal "bassist/play", cell(:bassist).send(:find_family_view_for_state, :play).virtual_path
      end
      
      should "find inherited play.html.erb" do
        assert_equal "bassist/play", cell(:bad_guitarist).send(:find_family_view_for_state, :play).virtual_path
      end
      
      should_eventually "find the EN-version if i18n instructs" do
        swap I18n, :locale => :en do
          assert_equal "bassist/yell.en.html.erb", cell(:bassist).find_family_view_for_state(:yell).virtual_path
        end
      end
      
      
      should_eventually "return an already cached family view"
    end
    
    context "delegation" do
      setup do
        @request.env["action_dispatch.request.request_parameters"] = {:song => "Creatures"}
        @controller = Class.new(ActionController::Base).new
        @controller.request = @request
        @cell = cell(:bassist)
      end
      
      should_eventually "delegate log" do
        assert_nothing_raised do
          cell(:bassist).class.logger.info("everything is perfect!")
        end
      end
      
      should "respond to session" do
        assert_kind_of Hash, @cell.session
      end
          
      should "respond to #params and return the request parameters" do
        assert_equal({"song" => "Creatures"}, cell(:bassist).params)
      end
      
      should "not merge #params and #options" do
        assert_equal({"song" => "Creatures"}, cell(:bassist, "song" => "Lockdown").params)
      end
    end
    
    
    # DISCUSS: do we really need that test anymore?
    should "precede cell ivars over controller ivars" do
      @controller.instance_variable_set(:@note, "E")
      BassistCell.class_eval do
        def slap; @note = "A"; render; end
      end
      assert_equal "Boing in A", render_cell(:bassist, :slap)
    end
    
  end   
end
