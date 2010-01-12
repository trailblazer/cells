require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

require File.dirname(__FILE__) + '/cells/test_cell'

class CellViewTest < ActionController::TestCase
  include CellsTestMethods
  
end