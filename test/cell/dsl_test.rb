require 'test_helper'

class DslTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "A dsl" do
    should "delegate missing methods to render cell" do
      assert_equal "Doo", Cell::Dsl.new(@controller, :bassist).play
    end
  end
  
end
