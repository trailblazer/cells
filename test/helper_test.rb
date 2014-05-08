require 'test_helper'
require 'app/cells/club_security'
require 'app/cells/club_security/guard_cell'
require 'app/cells/club_security/medic_cell'

module StringHelper
  def pick; "plong"; end
end

class DrummerCell < Cell::Rails
  helper StringHelper

  def assist
    render :inline => "<%= pick %>"
  end
end


class HelperTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  describe "a cell with included helper modules" do
    class SongCell < Cell::Rails
      include ActionView::Helpers::TagHelper  # for Rails 3.0.
      include ActionView::Helpers::AssetTagHelper

      def show
        controller.config.relative_url_root = "" if Cell.rails_version.~("3.0")
        image_tag("no-more-the-meek.jpg")
      end
    end

    it "allows using helpers using #controller on instance level" do
      alt = "No-more-the-meek"
      alt = "No more the meek" if Cell.rails_version >= "4.0"
      assert_equal "<img alt=\"#{alt}\" src=\"/images/no-more-the-meek.jpg\" />", render_cell("helper_test/song", :show)
    end
  end


  describe "a cell view" do
    it "have access to all helpers" do
      BassistCell.class_eval do
        def assist
          render :inline => "<%= submit_tag %>"
        end
      end

      assert_equal "<input name=\"commit\" type=\"submit\" value=\"Save changes\" />", render_cell(:bassist, :assist)
    end

    it "have access to methods declared with #helper_method" do
      BassistCell.class_eval do
        def help; "Great!"; end
        helper_method :help

        def assist
          render :inline => "<%= help %>"
        end
      end

      assert_equal "Great!", render_cell(:bassist, :assist)
    end

    it "have access to methods provided by helper" do
      assert_equal "plong", render_cell(:drummer, :assist)
    end

    it "mix in required helpers, only" do
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
    end

    it "include helpers only once" do
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
    end
  end
end
