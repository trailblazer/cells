# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')

class AssertionsHelperTest < ActionController::TestCase
  context "A TestCase" do
    setup do
      BassistCell.class_eval do
        def play; render; end
      end
    end
    
    should "respond to #render_cell" do
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "respond to #assert_selekt" do
      assert_selekt "<p>Doo</p>", "p", "Doo"
    end
    
    should "respond to #cell" do
      assert_kind_of BassistCell, cell(:bassist)
      assert_not cell(:bassist).respond_to? :opts
    end
    
    should "respond to #cell with a block" do
      assert_respond_to cell(:bassist) { def opts; @opts; end }, :opts
    end
    
    should "respond to #cell with options and block" do
      assert_equal({:topic => :peace}, cell(:bassist, :topic => :peace) { def opts; @opts; end }.opts)
    end
  end
end