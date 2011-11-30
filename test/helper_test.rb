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


class HelperTest < ActionController::TestCase
  include Cell::TestCase::TestMethods
  
  context "a cell view" do
    should "have access to all helpers" do
      BassistCell.class_eval do
        def assist
          render :inline => "<%= submit_tag %>"
        end
      end
      
      assert_equal "<input name=\"commit\" type=\"submit\" value=\"Save changes\" />", render_cell(:bassist, :assist)
    end
    
    should "have access to methods declared with helper_method" do
      BassistCell.class_eval do
        def help; "Great!"; end
        helper_method :help
          
        def assist
          render :inline => "<%= help %>"
        end
      end
      
      assert_equal "Great!", render_cell(:bassist, :assist)
    end
    
    should "have access to methods provided by helper" do
      assert_equal "plong", render_cell(:drummer, :assist)
    end
    
    should "mix in required helpers, only" do
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
    end
    
    should "include helpers only once" do
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
      assert_equal "false true", render_cell(:"club_security/medic", :help)
      assert_equal "true false", render_cell(:"club_security/guard", :help)
    end
  end
end
