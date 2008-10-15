require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

# usually done by rails' autoloading:
require File.dirname(__FILE__) + '/cells/test_cell'


class CellsCachingTest < Test::Unit::TestCase
  include CellsTestMethods
  
  def self.path_to_test_views
    RAILS_ROOT + "/vendor/plugins/cells/test/views/"
  end
  
  
  def test_caching
    cell = CachingCell.new(@controller)

    c = cell.render_state(:cached_state)
    
    assert_equal c, "i should remain the same forever!"
  end

end

class CachingCell < Cell::Base
  
  cache :cached_state
  def cached_state
    "i should remain the same forever!"
  end
  
end
