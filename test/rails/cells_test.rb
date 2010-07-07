require File.join(File.dirname(__FILE__), '/../test_helper')


class RailsCellsTest < ActiveSupport::TestCase
  context "A rails cell" do
    should "respond to view_paths" do
      assert_kind_of ActionView::PathSet, Cell::Rails.view_paths, "must be a PathSet for proper template caching/reloading (see issue#2)"
    end
    
    should "respond to view_paths=" do
      swap( Cell::Base, :view_paths => ['you', 'are', 'here'])  do
        assert_kind_of ActionView::PathSet, Cell::Base.view_paths, "must not wipe out the PathSet"
      end
    end
    
    
    context "invoking defaultize_render_options_for" do
      should "set default values" do
        cell(:bassist).class.default_template_format = :html  ### FIXME: remove and get it working.
        
        options = cell(:bassist).defaultize_render_options_for({}, :play)
        
        assert_equal :html, options[:template_format]
        assert_equal :play, options[:view]
      end
      
      should "allow overriding defaults" do
        assert cell(:bassist).defaultize_render_options_for({:view => :slap}, :play)[:view] == :slap
      end
    end
    
    context "invoking find_family_view_for_state" do
      should "### use find_template" do
        assert cell(:bassist).find_template("bassist/play")
        assert_raises ActionView::MissingTemplate do
          cell(:bassist).find_template("bassist/playyy")
        end
      end
      
      
      should "return play.html.erb" do
        assert_equal "bassist/play", cell(:bassist).find_family_view_for_state(:play).virtual_path
      end
      
      should "find inherited play.html.erb" do
        assert_equal "bassist/play", cell(:bad_guitarist).find_family_view_for_state(:play).virtual_path
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
        @request = ActionController::TestRequest.new 
        @request.env["action_dispatch.request.request_parameters"] = {:song => "Creatures"}
        @cell = cell(:bassist)
        @cell.request= @request
      end
      
      should_eventually "delegate log" do
        assert_nothing_raised do
          cell(:bassist).class.logger.info("everything is perfect!")
        end
      end
      
      should "respond to session" do
        assert_kind_of Hash, @cell.session
      end
    end
    
    
    should "precede cell ivars over controller ivars" do
      @controller.instance_variable_set(:@note, "E")
      BassistCell.class_eval do
        def slap; @note = "A"; render; end
      end
      assert_equal "Boing in A", render_cell(:bassist, :slap)
    end
    
  end   
end