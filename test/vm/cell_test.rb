require 'test_helper'

class CellTest < ActiveSupport::TestCase
  def test_rails_version
    version = Gem::Version.new(ActionPack::VERSION::STRING)
    assert_equal version, Cell.rails_version
  end
end
