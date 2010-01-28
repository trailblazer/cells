# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')

class MyTestCell < ::Cell::Base
  def state_with_instance_var
    @my_ivar = 'value from cell'
    render
  end
end

class BugsTest < ActionController::TestCase
  def test_controller_overriding_cell_ivars
    @controller.class_eval do
      attr_accessor :my_ivar
    end
    @controller.my_ivar = 'value from controller'

    cell = MyTestCell.new(@controller)
    c = cell.render_state(:state_with_instance_var)

    assert_equal 'value from cell', c
  end
end
