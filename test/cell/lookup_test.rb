require 'test_helper'

class LookupTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "A lookup process" do
    should "delegate its finder to a render cell" do
      assert_equal "Doo", Cell::Lookup.new(@controller)[:bassist].play
    end
  end
  
end
