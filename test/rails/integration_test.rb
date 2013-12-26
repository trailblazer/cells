require 'test_helper'

class ControllerMethodsTest < ActionController::TestCase
  tests MusicianController

  class SongCell < Cell::Rails
    include Cell::OptionsConstructor
  end

  test "#render_cell" do
    fix_relative_url_root

    get 'promotion'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", @response.body
  end

  test "#render_cell with arbitrary options" do
    BassistCell.class_eval do
      def enjoy(what, where="the bar")
        render :text => "I like #{what} in #{where}."
      end
    end

    @controller.instance_eval do
      def promotion
        render :text => render_cell(:bassist, :enjoy, "The Stranglers", "my room")
      end
    end
    get 'promotion'
    assert_equal "I like The Stranglers in my room.", @response.body
  end

  test "#render_cell with block" do
    get 'promotion_with_block'
    assert_equal "Doo",       @response.body
    assert_equal BassistCell, @controller.flag
  end

  test "#cell_for" do
    @controller.cell_for(:bassist).must_be_instance_of BassistCell
  end

  test "#cell_for with options" do
    @controller.cell_for("controller_methods_test/song", :title => "We Called It America").
      title.must_equal "We Called It America"
  end

  if Cell.rails4_0? or Cell.rails4_1_or_more?
    test "#render_cell for engine" do
      @controller.render_cell(:label, :show).must_equal "Fat Wreck"
    end
  end
end


class ViewMethodsTest < ActionController::TestCase
  tests MusicianController

  test "#cell_for" do
    @controller.instance_eval do
      def title
      end
    end

    get :title
    @response.body.must_equal "First Call"
  end

  test "#render_cell" do
    fix_relative_url_root

    get 'featured'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", @response.body
  end

  test "#render_cell with a block" do
    get 'featured_with_block'
    assert_equal "Boing in D from BassistCell\n", @response.body
  end

  test "#render_cell in a haml view" do
    fix_relative_url_root

    get 'hamlet'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />\n", @response.body
  end

  test "make params (and friends) available in a cell" do
    BassistCell.class_eval do
      def listen
        render :text => "That's a #{params[:note]}"
      end
    end
    get 'skills', :note => "D"
    assert_equal "That's a D", @response.body
  end

  test "respond to #config" do
    BassistCell.class_eval do
      def listen
        render :view => 'contact_form'  # form_tag internally calls config.allow_forgery_protection
      end
    end
    get 'skills'
    assert_equal "<form accept-charset=\"UTF-8\" action=\"musician/index\" method=\"post\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div>\n", @response.body
  end
end
