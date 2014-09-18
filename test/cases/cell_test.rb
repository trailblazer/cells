require 'test_helper'

class CachingUnitTest < MiniTest::Spec

  describe Cell::VERSION do
    it 'has a version' do
      assert Cell::VERSION::STRING
    end
  end
end