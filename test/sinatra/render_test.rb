require File.join(File.dirname(__FILE__), '/../test_helper')



require 'cells/cell/sinatra'  ### FIXME.




class SinatraRenderTest < ActiveSupport::TestCase
  
  def render_cell(name, state, opts={})  ### FIXME.

      cell = ::Cell::Base.create_cell_for(nil, name, opts)
      return cell.render_state(state)
  end  
  
  
  context "Invoking render" do
    setup do
      Cell::Base.framework = :sinatra
      
      BassistCell.class_eval do
        def play; render; end
      end
      
      BadGuitaristCell.class_eval do
        def play; render; end # inherits from BassistCell.
      end
    end
    
    should "render a plain view" do
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    # inheriting
    should "inherit play.html.erb from BassistCell" do
      assert_equal "Doo", render_cell(:bad_guitarist, :play)
    end
  end
end