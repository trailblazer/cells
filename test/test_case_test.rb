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
    
    should "respond to #assert_selector with 3 args" do
      assert_selector "p", "Doo", "<p>Doo</p>y"
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
    
    context "#view_assigns" do
      should "be emtpy when nothing was set" do
        render_cell(:bassist, :play)
        assert_equal({}, view_assigns)
      end
      
      should "return the instance variables from the last #render_cell" do
        BassistCell.class_eval do
          def sleep
            @duration = "8h"
          end
        end
        render_cell(:bassist, :sleep)
        assert_equal({:duration => "8h"}, view_assigns)
      end

      should "return the instance variables from the last #render_cell accepting options" do
        BassistCell.class_eval do
          def run
            @duration = @opts[:duration]
          end
        end
        render_cell(:bassist, :run, :duration=> "8h")
        assert_equal("8h", assigns(:duration))
      end

    end
    
    context "in declarative tests" do
      should "respond to TestCase.tests" do
        self.class.tests BassistCell
        assert_equal BassistCell, self.class.controller_class
      end
      
      should "infer the cell name" do
        class SingerCell < Cell::Base
        end
        
        class SingerCellTest < Cell::TestCase
        end
        
        assert_equal SingerCell, SingerCellTest.new(:cell_test).class.controller_class
      end
      
      context "with invoke" do
        setup do
          self.class.tests BassistCell
        end
        
        should "provide #invoke" do
          assert_equal "Doo", invoke(:play)
        end
        
        should "provide #last_invoke" do
          assert_equal nil, last_invoke
          assert_equal "Doo", invoke(:play)
          assert_equal "Doo", last_invoke
        end
        
        should "provide #invoke accepting opts" do
          #assert_equal "Doo", invoke(:play)
        end
        
        should "provide assert_select" do
          invoke :play
          assert_select "a", 0
        end
      end
    end
  end
end
