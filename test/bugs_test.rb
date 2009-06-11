require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'


class MyTestCell < Cell::Base
  def state_with_instance_var
    @my_ivar = "value from cell"
    nil
  end
end


class CellsTest < ActionController::TestCase
  include CellsTestMethods
  
  def test_controller_overriding_cell_ivars
    @controller.class_eval do
      attr_accessor :my_ivar
    end
    @controller.my_ivar = "value from controller"
    
    cell = MyTestCell.new(@controller)
    c = cell.render_state(:state_with_instance_var)
    assert_equal "value from cell", c
  end
end