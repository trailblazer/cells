# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')

class ACell < ::Cell::Base
  def existing_view
    @a = 'a'
    render
  end
end

class ActionControllerRenderTest < ActionController::TestCase
  include Cells::Rails::ActionController

  def test_render_cell
    assert_equal 'A/existing_view/a', render_cell(:a, :existing_view)
  end

  # Backward-compability.
  def test_render_cell_to_string
    assert_equal render_cell_to_string(:a, :existing_view), render_cell(:a, :existing_view)
  end
end

class ActionControllerRenderTest < ActionController::TestCase
  include Cells::Rails::ActionView

  def test_render_cell
    assert_equal 'A/existing_view/a', render_cell(:a, :existing_view)
  end

  # Backward-compability.
  def test_render_cell_to_string
    assert_equal render_cell_to_string(:a, :existing_view), render_cell(:a, :existing_view)
  end
end
