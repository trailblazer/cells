require 'test_helper'

class SongwriterCell < BassistCell
  include Cell::Deprecations
end


class DeprecationsTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  context "#render_state" do
    should "work without args and provide #options" do
      SongwriterCell.class_eval do
        def listen
          render :text => options[:note]
        end
      end
      assert_equal "D", cell(:songwriter, :note => "D").render_state(:listen)
    end
    
    include ActiveSupport::Testing::Deprecation
    should "mark @options as deprecated, but still work" do
      res = nil
      assert_deprecated do
        res = cell(:songwriter, :song => "Lockdown").instance_eval do
          options[:song]
        end
      end
      assert_equal "Lockdown", res
    end
  end
  
  context "render_cell_for" do
    should "make options available in #options if not receiving state-args" do
      SongwriterCell.class_eval do
        def listen
          render :text => options[:note]
        end
      end
      assert_equal "C-minor", Cell::Rails.render_cell_for(:songwriter, :listen, @controller, :note => "C-minor")
    end
      
    should "pass options as state-args and still set #options otherwise" do
      SongwriterCell.class_eval do
        def listen(args)
          render :text => args[:note] + options[:note].to_s
        end
      end
      assert_equal "C-minorC-minor", Cell::Rails.render_cell_for(:songwriter, :listen, @controller, :note => "C-minor")
    end
  end
  
  context "#state_accepts_args?" do
    should "be false if state doesn't want args" do
      assert_not cell(:songwriter).state_accepts_args?(:play)
    end
    
    should "be true for one arg" do
      assert(cell(:songwriter) do 
        def listen(args) end 
      end.state_accepts_args?(:listen))
    end
    
    should "be true for multiple arg" do
      assert(cell(:songwriter) do 
        def listen(what, where) end 
      end.state_accepts_args?(:listen))
    end
    
    should "be true for multiple arg with defaults" do
      assert(cell(:songwriter) do 
        def listen(what, where="") end 
      end.state_accepts_args?(:listen))
    end
  end
  
  context ".cache" do
    should "still be able to use options in the block" do
      SongwriterCell.class_eval do
        def count(args)
          render :text => args[:int]
        end
        
        cache :count do |cell, i|
          (cell.options[:int] % 2)==0 ? {:count => "even"} : {:count => "odd"}
        end
      end
      
      assert_equal "1", render_cell(:songwriter, :count, :int => 1)
      assert_equal "2", render_cell(:songwriter, :count, :int => 2)
      assert_equal "1", render_cell(:songwriter, :count, :int => 3)
      assert_equal "2", render_cell(:songwriter, :count, :int => 4)
    end
  end
end
