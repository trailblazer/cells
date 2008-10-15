require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

# usually done by rails' autoloading:
require File.dirname(__FILE__) + '/cells/test_cell'


class CellsCachingTest < Test::Unit::TestCase
  include CellsTestMethods
  
  def setup
    super
    @cc = CachingCell.new(@controller)
  end
  
  def self.path_to_test_views
    RAILS_ROOT + "/vendor/plugins/cells/test/views/"
  end
  
  
  def test_caching
    c = @cc.render_state(:cached_state)
    
    assert_equal c, "i should remain the same forever!"
  end
  
  def test_cache_key
    assert_equal "cells/CachingCell/some_state", @cc.cache_key(:some_state)
    assert_equal "cells/CachingCell/some_state/param=9", @cc.cache_key(:some_state, :param => 9)
  end
end

class CachingCell < Cell::Base
  
  cache :cached_state
  def cached_state
    "i should remain the same forever!"
  end
  
end
