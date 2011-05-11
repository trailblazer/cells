require 'test_helper'

class MusicianCell < Cell::Base
  
end

class PianistCell < MusicianCell
end

class SingerCell < MusicianCell
end


class CellModuleTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "Cell::Base" do
    
    # FUNCTIONAL:
    context "render_cell_for" do
      should "render the actual cell" do
        assert_equal "Doo", Cell::Base.render_cell_for(@controller, :bassist, :play)
      end
      
      should "accept a block, passing the cell instance" do
        flag = false
        html = Cell::Base.render_cell_for(@controller, :bassist, :play) do |cell|
          assert_equal BassistCell, cell.class
          flag = true
        end
        
        assert_equal "Doo", html
        assert flag
      end
      
      should "make options available in #options if not receiving state-args" do
        BassistCell.class_eval do
          def listen
            render :text => options[:note]
          end
        end
        assert_equal "C-minor", Cell::Base.render_cell_for(@controller, :bassist, :listen, :note => "C-minor")
      end
      
      should "pass options as state-args and still set #options otherwise" do
        BassistCell.class_eval do
          def listen(args)
            render :text => args[:note] + options[:note].to_s
          end
        end
        assert_equal "C-minorC-minor", Cell::Base.render_cell_for(@controller, :bassist, :listen, :note => "C-minor")
      end
    end
    
    context "create_cell_for" do
      should "call the cell's builders, eventually returning a different class" do
        class DrummerCell < BassistCell
          build do
            BassistCell
          end
        end
        
        assert_instance_of BassistCell, Cell::Base.create_cell_for(@controller, "cell_module_test/drummer", :play)
      end
    end
    
    context "calling build" do
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
        assert_equal BassistCell,  Cell::Base.build_class_for(@controller, MusicianCell, {})
      end
      
      should "limit the builder to the receiving class" do
        assert_equal PianistCell,   Cell::Base.build_class_for(@controller, PianistCell, {})   # don't inherit anything.
        @controller.bassist = true
        assert_equal BassistCell,   Cell::Base.build_class_for(@controller, MusicianCell, {})
      end
      
      should "chain build blocks and execute them by ORing them in the same order" do
        MusicianCell.build do
          PianistCell unless bassist
        end
        
        MusicianCell.build do
          UnknownCell # should never be executed.
        end
        
        assert_equal PianistCell, Cell::Base.build_class_for(@controller, MusicianCell, {})  # bassist is false.
        @controller.bassist = true
        assert_equal BassistCell, Cell::Base.build_class_for(@controller, MusicianCell, {})
      end
      
      should "use the original cell if no builder matches" do
        assert_equal MusicianCell, Cell::Base.build_class_for(@controller, MusicianCell, {})  # bassist is false.
      end
      
      should "stop at the first builder returning a valid cell" do
        
      end
      
      should "pass options to the block" do
        BassistCell.build do |opts|
          SingerCell if opts[:sing_the_song]
        end
        assert_equal BassistCell, Cell::Base.build_class_for(@controller, BassistCell, {})
        assert_equal SingerCell,  Cell::Base.build_class_for(@controller, BassistCell, {:sing_the_song => true})
      end
      
      should "create the original target class if no block matches" do
        assert_equal PianistCell, Cell::Base.build_class_for(@controller, PianistCell, {})
      end
      
      should "builders should return an empty array per default" do
        assert_equal [], PianistCell.builders
      end
    end
    
    should "provide class_from_cell_name" do
      assert_equal BassistCell, ::Cell::Base.class_from_cell_name('bassist')
    end
    
    if Cells.rails3_0?
      should "provide possible_paths_for_state" do
        assert_equal ["bad_guitarist/play", "bassist/play", "cell/rails/play"], cell(:bad_guitarist).send(:possible_paths_for_state, :play)
      end
      
      should "provide Cell.cell_name" do
        assert_equal 'bassist', cell(:bassist).class.cell_name
      end
      
      should "provide cell_name for modules, too" do
        class SingerCell < Cell::Base
        end
        
        assert_equal "cell_module_test/singer", CellModuleTest::SingerCell.cell_name
      end
    end
    
    context "#state_accepts_args?" do
      should "be false if state doesn't want args" do
        assert_not cell(:bassist).state_accepts_args?(:play)
      end
      
      should "be true for one arg" do
        assert(cell(:bassist) do 
          def listen(args) end 
        end.state_accepts_args?(:listen))
      end
      
      should "be true for multiple arg" do
        assert(cell(:bassist) do 
          def listen(what, where) end 
        end.state_accepts_args?(:listen))
      end
      
      should "be true for multiple arg with defaults" do
        assert(cell(:bassist) do 
          def listen(what, where="") end 
        end.state_accepts_args?(:listen))
      end
    end
  end
end
