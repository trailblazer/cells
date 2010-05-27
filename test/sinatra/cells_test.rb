require File.join(File.dirname(__FILE__), '/../test_helper')


class SinatraCellsTest < ActiveSupport::TestCase
  context "A sinatra cell" do
    setup do
      TestConfiguration.sinatra!
    end
    
    teardown do
      TestConfiguration.sinatra!
      BackgroundSingerCell.views = Cell::Sinatra.views
    end
    
    should "respond to views" do
      BackgroundSingerCell.views = "another/dir"
      Cell::Sinatra.views = "test/dir"
      assert_equal "test/dir", Cell::Sinatra.views
      assert_equal "another/dir", BackgroundSingerCell.views
    end
    
    context "invoking defaultize_render_options_for" do
      should "set default values" do
        options = cell(:singer).defaultize_render_options_for({}, :play)
        
        assert_equal :erb,  options[:engine]
        assert_equal :play, options[:view]
        assert options.has_key?(:views)
      end
      
      should "allow overriding defaults" do
        assert cell(:singer).defaultize_render_options_for({:engine => :haml}, :play)[:engine] == :haml
      end
    end
    
    context "invoking find_family_view_for" do
      setup do
        @views = File.join(File.dirname(__FILE__), '/../app/cells')
      end
      
      should "return sing.html.erb" do
        assert_equal "singer/sing", cell(:singer).find_family_view_for(:sing, {:template_format => :html, :engine => :erb}, @views)
      end
      
      should "return nil when non-existent" do
        assert_nil cell(:singer).find_family_view_for(:play, {:template_format => :js, :engine => :erb}, @views)
      end
      
      should "find inherited sing.html.erb" do
        assert_equal "singer/sing", cell(:background_singer  ).find_family_view_for(:sing, {:template_format => :html, :engine => :erb}, @views)
      end
      
      should_eventually "return an already cached family view"
    end
    
  end   
end