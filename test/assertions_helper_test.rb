# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')

class AssertionsHelperTest < ActionController::TestCase
  context "A TestCase" do
    setup do
      TestCell.class_eval do
        def beep; render; end
      end
    end
    
    context "calling #cell_mock" do
      should "return a cell instance" do
        assert_kind_of Cell::Base, cell_mock
      end
      
      should "accept a block" do
        assert_respond_to cell_mock { def beep; end}, :beep
      end
    end
    
    should "respond to #render_cell" do
      assert_equal "<h1>beep!</h1>", render_cell(:test, :beep)
    end
    
    should "respond to #assert_selekt" do
      assert_selekt render_cell(:test, :beep), "h1", "beep!"
    end
    
    should "respond to #cell" do
      assert_kind_of TestCell, cell(:test)
      assert_not cell(:test).respond_to? :opts
    end
    
    should "respond to #cell with a block" do
      assert_respond_to cell(:test) { def opts; @opts; end }, :opts
    end
    
    should "respond to #cell with options and block" do
      assert_equal({:topic => :peace}, cell(:test, :topic => :peace) { def opts; @opts; end }.opts)
    end
  end
end