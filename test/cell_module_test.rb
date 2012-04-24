require 'test_helper'

class MusicianCell < Cell::Rails
end

class PianistCell < MusicianCell
end

class SingerCell < MusicianCell
end

# Used in CellBaseTest.
class ShouterCell < Cell::Base
  def sing(first)
    first + render
  end
end


class CellBaseTest < MiniTest::Spec
  describe "Cell::Base" do
    it "still have a working #url_for" do
      cell = Cell::Base.new
      cell.instance_eval do
        # You can use #default_url_options.
        def default_url_options
          {:host => "cells-project.org"}
        end
        
      end
      # You could also use a *_url or *_path helper method here.
      assert_equal "http://cells-project.org/dashboard/show", cell.url_for(:action => :show, :controller => :dashboard)
    end
    
    describe ".render_cell_for" do
      it "invokes controller-less cell" do
        Cell::Base.view_paths= ["test/app/cells"]
        assert_equal "YAAAaaargh!\n", Cell::Base.render_cell_for(:shouter, :sing, "Y")
      end
    end
  end
end


class CellModuleTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  context "Cell::Rails" do
    # FUNCTIONAL:
    context "render_cell_for" do
      should "render the actual cell" do
        assert_equal "Doo", Cell::Rails.render_cell_for(:bassist, :play, @controller)
      end
      
      should "accept a block, passing the cell instance" do
        flag = false
        html = Cell::Rails.render_cell_for(:bassist, :play, @controller) do |cell|
          assert_equal BassistCell, cell.class
          flag = true
        end
        
        assert_equal "Doo", html
        assert flag
      end
    end
    
    context "create_cell_for" do
      should "call the cell's builders, eventually returning a different class" do
        class DrummerCell < BassistCell
          build do
            BassistCell
          end
        end
        
        assert_instance_of BassistCell, Cell::Rails.create_cell_for("cell_module_test/drummer", :play, @controller)
      end
    end
    
    context "#create_cell_for with #build" do
      setup do
        @controller.class_eval do
          attr_accessor :bassist
        end
        
        MusicianCell.build do
          BassistCell if bassist
        end
      end
      
      teardown do
        MusicianCell.class_eval do
          @builders = false
        end
        BassistCell.class_eval do
          @builders = false
        end
      end
      
      should "execute the block in controller context" do
        @controller.bassist = true
        assert_is_a BassistCell,  Cell::Rails.create_cell_for(:musician, @controller)
      end
      
      should "limit the builder to the receiving class" do
        assert_is_a PianistCell,   Cell::Rails.create_cell_for(:pianist, @controller)   # don't inherit anything.
        @controller.bassist = true
        assert_is_a BassistCell,   Cell::Rails.create_cell_for(:musician, @controller)
      end
      
      should "chain build blocks and execute them by ORing them in the same order" do
        MusicianCell.build do
          PianistCell unless bassist
        end
        
        MusicianCell.build do
          UnknownCell # should never be executed.
        end
        
        assert_is_a PianistCell, Cell::Rails.create_cell_for(:musician, @controller)  # bassist is false.
        @controller.bassist = true
        assert_is_a BassistCell, Cell::Rails.create_cell_for(:musician, @controller)
      end
      
      should "use the original cell if no builder matches" do
        assert_is_a MusicianCell, Cell::Rails.create_cell_for(:musician, @controller)  # bassist is false.
      end
      
      should "stop at the first builder returning a valid cell" do
        
      end
      
      should "pass options to the block" do
        BassistCell.build do |opts|
          SingerCell if opts[:sing_the_song]
        end
        assert_kind_of BassistCell, Cell::Rails.create_cell_for(:bassist, @controller, {})
        assert_kind_of SingerCell,  Cell::Rails.create_cell_for(:bassist, @controller, {:sing_the_song => true})
      end
      
      should "create the original target class if no block matches" do
        assert_kind_of PianistCell, Cell::Rails.create_cell_for(:pianist, @controller)
      end
      
      should "builders should return an empty array per default" do
        assert_equal [], PianistCell.send(:builders)
      end
    end
    
    should "provide class_from_cell_name" do
      assert_equal BassistCell, ::Cell::Rails.class_from_cell_name('bassist')
    end
    
    if Cells.rails3_0?
      should "provide possible_paths_for_state" do
        assert_equal ["bad_guitarist/play", "bassist/play"], cell(:bad_guitarist).send(:possible_paths_for_state, :play)
      end
      
      should "provide Cell.cell_name" do
        assert_equal 'bassist', cell(:bassist).class.cell_name
      end
      
      should "provide cell_name for modules, too" do
        class SingerCell < Cell::Rails
        end
        
        assert_equal "cell_module_test/singer", CellModuleTest::SingerCell.cell_name
      end
    end
  end
end
