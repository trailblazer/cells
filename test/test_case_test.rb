require 'test_helper'

class TestCaseTest < Cell::TestCase
  
  context "A TestCase" do
    setup do
      @test = Cell::TestCase.new(:cell_test)
      
      BassistCell.class_eval do
        def play; render; end
      end
    end
    
    
    should "respond to #render_cell" do
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "respond to #assert_select with 3 args" do
      assert_select "p", "Doo", "<p>Doo</p>y"
    end
    
    should "respond to #cell" do
      assert_kind_of BassistCell, cell(:bassist)
      assert !cell(:bassist).respond_to?(:opts)
    end
    
    should "respond to #cell with a block" do
      assert_respond_to cell(:bassist) { def opts; @opts; end }, :opts
    end
    
    should "respond to #cell with options and block" do
      assert_equal({:topic => :peace}, cell(:bassist, :topic => :peace) { def opts; @opts; end }.opts)
    end
    
    should "respond to TestCase.tests" do
      
    end
  end
end
