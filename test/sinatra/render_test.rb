require File.join(File.dirname(__FILE__), '/../test_helper')



require 'cells/cell/sinatra'  ### FIXME.




class SinatraRenderTest < ActiveSupport::TestCase
  
  def render_cell(name, state, opts={})  ### FIXME.

      cell = ::Cell::Base.create_cell_for(nil, name, opts)
      return cell.render_state(state)
  end  
  
  context "Sinatra::View" do
    should "respond to copy_ivars" do
      view = ::Cells::Cell::Sinatra::View.new
      
      assert_nil view.instance_variable_get(:@model)
      
      view.copy_ivars( {:@model => 'precision'})
      assert_equal 'precision', view.instance_variable_get(:@model)
    end
  end
  
  context "SinatraMethods" do
    should "respond to assigns" do
      Cell::Base.framework = :sinatra
      assert_kind_of Hash, cell(:bassist).assigns
    end
  end
  
  context "Invoking render" do
    setup do
      Cell::Base.framework = :sinatra
      
      BassistCell.class_eval do
        def play; render; end
        def slap; @note = "D"; render; end
      end
      
      BadGuitaristCell.class_eval do
        def play; render; end # inherits from BassistCell.
      end
    end
    
    should "render a plain view" do
      assert_equal "Doo", render_cell(:bassist, :play)
    end
    
    should "render instance variables from the cell" do
      assert_equal "Boing in D", render_cell(:bassist, :slap)
    end
    
    # inheriting
    should "inherit play.html.erb from BassistCell" do
      assert_equal "Doo", render_cell(:bad_guitarist, :play)
    end
  end
end