require 'test_helper'

class RailsCellsTest < MiniTest::Spec
  include Cell::TestCase::TestMethods
  
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end
  
  describe "#render_state" do
    it "work without args" do
      BassistCell.class_eval do
        def listen
          render :text => "That's a D!"
        end
      end
      assert_equal "That's a D!", cell(:bassist).render_state(:listen)
    end
    
    it "accept state-args" do
      BassistCell.class_eval do
        def listen(args)
          render :text => args[:note]
        end
      end
      assert_equal "D", cell(:bassist).render_state(:listen, :note => "D")
    end
    
    it "accept state-args with default parameters" do
      BassistCell.class_eval do
        def listen(first, second="D")
          render :text => first+second
        end
      end
      assert_equal "AD", cell(:bassist).render_state(:listen, "A")
    end
  end
  
  
  describe "A rails cell" do
    it "respond to DEFAULT_VIEW_PATHS" do
      assert_equal ["app/cells"], Cell::Rails::DEFAULT_VIEW_PATHS
    end
    
    it "respond to .setup_view_paths!" do
      swap( Cell::Rails, :view_paths => [])  do
        Cell::Rails.setup_view_paths!
        if Cell.rails3_2_or_more? or Cell.rails4_0_or_more?
          assert_equal ActionView::PathSet.new(Cell::Rails::DEFAULT_VIEW_PATHS).paths, Cell::Rails.view_paths.paths
        else
          assert_equal ActionView::PathSet.new(Cell::Rails::DEFAULT_VIEW_PATHS), Cell::Rails.view_paths
        end
      end
    end
    
    it "respond to view_paths" do
      assert_kind_of ActionView::PathSet, Cell::Rails.view_paths, "must be a PathSet for proper template caching/reloading (see issue#2)"
    end
    
    it "respond to view_paths=" do
      swap( Cell::Rails, :view_paths => ['you', 'are', 'here'])  do
        assert_kind_of ActionView::PathSet, Cell::Rails.view_paths, "must not wipe out the PathSet"
      end
    end
    
    it "respond to #request" do
      assert_equal @request, cell(:bassist).request
    end
    
    it "respond to #config" do
      assert_equal({}, cell(:bassist).config)
    end
    
    
    if Cell.rails3_0?
      describe "invoking find_family_view_for_state" do
        it "raise an error when a template is missing" do
          assert_raises ActionView::MissingTemplate do
            cell(:bassist).find_template("bassist/playyy")
          end
          
          #puts "format: #{cell(:bassist).find_template("bassist/play.js").formats.inspect}"
        end
        
        it "return play.html.erb" do
          assert_equal "bassist/play", cell(:bassist).send(:find_family_view_for_state, :play).virtual_path
        end
        
        it "find inherited play.html.erb" do
          assert_equal "bassist/play", cell(:bad_guitarist).send(:find_family_view_for_state, :play).virtual_path
        end
      end
    end
    
    describe "delegation" do
      before do
        @request.env["action_dispatch.request.request_parameters"] = {:song => "Creatures"}
        @controller = Class.new(ActionController::Base).new
        @controller.request = @request
        @cell = cell(:bassist)
      end
      
      it "delegate log" do
        skip
        assert_nothing_raised do
          cell(:bassist).class.logger.info("everything is perfect!")
        end
      end
      
      it "respond to session" do
        assert_kind_of Hash, @cell.session
      end
          
      it "respond to #params and return the request parameters" do
        assert_equal({"song" => "Creatures"}, cell(:bassist).params)
      end
      
      it "not merge #params and #options" do
        assert_equal({"song" => "Creatures"}, cell(:bassist, "song" => "Lockdown").params)
      end
    end
  end   
end
