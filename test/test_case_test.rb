require 'test_helper'

class TestCaseTest < Cell::TestCase
  include ActiveSupport::Testing::Deprecation
    
  context "A TestCase" do
    setup do
      @test = Cell::TestCase.new(:cell_test)
      
      BassistCell.class_eval do
        def play; render; end
      end
    end
    
    context "#render_cell" do
      should "invokes the state" do
        assert_equal "Doo", render_cell(:bassist, :play)
      end
      
      should "accept state args" do
        assert_equal "*shouts* Listen!\n", render_cell(:bassist, :shout, :words => "Listen!")
      end
    end
    
    should "respond to #assert_selector with 3 args" do
      assert_selector "p", "Doo", "<p>Doo</p>y"
    end
    
    context "#cell" do
      should "create a cell" do
        assert_kind_of BassistCell, cell(:bassist)
      end
      
      should "accept a block" do
        assert_respond_to cell(:bassist){ def whatever; end }, :whatever
      end
    end
    
    context "#subject_cell" do
      should "return the last rendered cell" do
        render_cell(:bassist, :play)
        assert_kind_of BassistCell, subject_cell
      end
    end
    
    
    context "#view_assigns" do
      should "be emtpy when nothing was set" do
        render_cell(:bassist, :play)
        if Cells.rails3_0?
          assert_equal([:lookup_context], view_assigns.keys)
        else
          assert_equal({}, view_assigns)
        end
      end
      
      should "return the instance variables from the last #render_cell" do
        BassistCell.class_eval do
          def sleep
            @duration = "8h"
          end
        end
        render_cell(:bassist, :sleep)
        if Cells.rails3_0?
          assert_equal([:lookup_context, :duration], view_assigns.keys)
          assert_equal("8h", view_assigns[:duration])
        else
          assert_equal({:duration => "8h"}, view_assigns)
        end
      end
    end
    
    context "in declarative tests" do
      should "respond to TestCase.tests" do
        self.class.tests BassistCell
        assert_equal BassistCell, self.class.controller_class
      end
      
      should "infer the cell name" do
        class SingerCell < Cell::Rails
        end
        
        class SingerCellTest < Cell::TestCase
        end
        
        assert_equal SingerCell, SingerCellTest.new(:cell_test).class.controller_class
      end
      
      context "with #invoke" do
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
        
        should "provide #invoke accepting options" do
          #assert_equal "Doo", invoke(:play)
        end
        
        should "provide #invoke accepting args" do
          assert_equal "*shouts* Listen!\n", invoke(:shout, :words => "Listen!")
        end
        
        should "provide assert_select" do
          invoke :promote
          assert_select "a", "vd.com"
        end
      end
      
      context "#setup_test_states_in" do
        should "add the :in_view state" do
          c = cell(:bassist)
          assert_not c.respond_to?(:in_view)
          
          setup_test_states_in(c)
          assert_equal "Cells rock.", c.render_state(:in_view, lambda{"Cells rock."})
        end
      end
      
      context "#in_view" do
        should "execute the block in a real view" do
          content = "Cells rule."
          @test.setup
          assert_equal("<h1>Cells rule.</h1>", @test.in_view(:bassist) do content_tag("h1", content) end)
        end
      end
    end
  end
end
