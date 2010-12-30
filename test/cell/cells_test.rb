require 'test_helper'

class CellsConfigurationTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "A configuration dsl" do
    should "defer the cell to the configured one" do
      Cells.config do
        logins do
          BassistCell
        end
      end
      assert_equal "Doo", Cell::Dsl.new(@controller, :logins).play
    end
  end
  
end
