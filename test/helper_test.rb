# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')

module CellsTestHelper
  def a_mysterious_helper_method
    'mysterious'
  end
end

module AnotherHelper
  def senseless_helper_method
    'senseless'
  end
end

class HelperUsingCell < ::Cell::Base
  helper CellsTestHelper
  helper_method :my_helper_method

  def state_with_helper_invocation
    render
  end

  def state_with_automatic_helper_invocation
    render
  end

  def state_with_helper_method_invocation
    render
  end

  def state_using_application_helper
    render
  end

  protected

    def my_helper_method
      'helped by a method'
    end
end

class TwoHelpersIncludingCell < HelperUsingCell
  helper AnotherHelper

  def state_using_another_helper
    render
  end
end

class HelperUsingSubCell < HelperUsingCell
end

class HelperTest < ActionController::TestCase
  def test_helper
    cell = HelperUsingCell.new(@controller)

    c = cell.render_state(:state_with_helper_invocation)
    assert_selekt c, 'p#stateWithHelperInvocation', 'mysterious'
  end

  # ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), 'helpers')
  # test if the HelperUsingCellHelper is automatically included:

  ## FIXME: currently loading should happen in render_view_for_state, since
  #   there seems to be no automatic mechanism.
  def dont_test_auto_helper
    # ActionController::Base.helpers_dir = File.join(File.dirname(__FILE__), 'helpers')
    ::Cell::Base.helpers_dir = File.join(File.dirname(__FILE__), 'app', 'helpers')
    setup

    cell = HelperUsingCell.new(@controller)
    c = cell.render_state(:state_with_automatic_helper_invocation)

    assert_selekt c, 'p#stateWithAutomaticHelperInvocation', 'automatic'
  end

  def test_helper_method
    cell = HelperUsingCell.new(@controller)
    c = cell.render_state(:state_with_helper_method_invocation)

    assert_selekt c, 'p#stateWithHelperMethodInvocation', 'helped by a method'
  end

  def test_helper_with_subclassing
    cell = HelperUsingSubCell.new(@controller)
    c = cell.render_state(:state_with_helper_invocation)

    assert_selekt c, 'p#stateWithHelperInvocation', 'mysterious'
  end

  def test_helper_including_and_cleanup
    # this cell includes a helper, and uses it:
    cell = HelperUsingCell.new(@controller)
    c = cell.render_state(:state_with_helper_invocation)

    assert_selekt c, 'p#stateWithHelperInvocation', 'mysterious'

    # this cell doesn't include the helper, but uses it anyway, which should
    # produce an error:
    cell = TestCell.new(@controller)

    # assert_raises (NameError) do
    assert_raises (::ActionView::TemplateError) do
      cell.render_state(:state_with_not_included_helper_method)
    end
  end

  def test_helpers_included_on_different_inheritance_levels
    cell = TwoHelpersIncludingCell.new(@controller)
    c = cell.render_state(:state_with_helper_invocation)

    assert_selekt c, 'p#stateWithHelperInvocation', 'mysterious'

    c = cell.render_state(:state_using_another_helper)

    assert_selekt c, 'p#stateUsingAnotherHelper', 'senseless'
  end

  def test_application_helper
    cell = HelperUsingCell.new(@controller)
    c = cell.render_state(:state_using_application_helper)

    assert_selekt c, 'p#stateUsingApplicationHelper', 'global'
  end

  def test_rails_helper_url_for
    cell = HelperUsingCell.new(@controller)
    cell.instance_eval do
      def state_with_url_for
        render :inline => "<%= url_for '/test' %>"
      end
    end
    c = cell.render_state(:state_with_url_for)

    assert_equal '/test', c
  end
end
