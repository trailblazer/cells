require 'test_helper'

class DirectorCell < Cell::Rails
  attr_reader :count
  
  def initialize(*)
    super
    @count = 0
  end
  
  cache :tock
  def tock
    @count += 1
    render :text => @count
  end
end

class CachingUnitTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  setup do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
    @cell   = cell(:director)
    @class  = @cell.class
  end
  
  
  context ".state_cache_key" do
    should "accept state only" do
      assert_equal "cells/director/count/", @class.state_cache_key(:count)
    end
    
    should "accept hash as key parts" do
      assert_equal "cells/director/count/a=1&b=2", @class.state_cache_key(:count, :b=>2, :a=>1)
    end
    
    should "accept array as key parts" do
      assert_equal "cells/director/count/1/2/3", @class.state_cache_key(:count, [1,2,3])
    end
    
    should "accept string as key parts" do
      assert_equal "cells/director/count/1/2", @class.state_cache_key(:count, "1/2")
    end
    
    should "accept nil as key parts" do
      assert_equal "cells/director/count/", @class.state_cache_key(:count, nil)
    end
  end
  
  
  context ".state_cached?" do
    should "return true for cached" do
      assert @class.send :state_cached?, :count
    end
    
    should "return false otherwise" do
      assert_not @class.send :state_cached?, :sing
    end
  end
  
  
  context ".cache?" do
    should "return true for cached" do
      assert @cell.class.cache?(:count)
    end
    
    should "return false otherwise" do
      assert_not @cell.class.cache?(:sing)
    end
    
    context "perform_caching turned off" do
      teardown do
        ::ActionController::Base.perform_caching = true
      end
      
      should "always return false if caching turned-off" do
        ::ActionController::Base.perform_caching = false
        assert_not @cell.class.cache?(:count)
        assert_not @cell.class.cache?(:sing)
      end
    end
  end
  
  
  context ".expire_cache_key" do
    setup do
      @key = @class.state_cache_key(:tock)
      assert_equal "1", render_cell(:director, :tock)
      assert_equal "1", @class.cache_store.read(@key)
    end
    
    should "delete the state from cache" do
      @class.expire_cache_key(@key)
      assert_not @class.cache_store.read(@key)
    end
    
    should "be available in controllers for sweepers" do
      MusicianController.new.expire_cell_state(DirectorCell, :tock)
      assert_not @class.cache_store.read(@key)
    end
    
    should "accept cache options" do
      key = @class.state_cache_key(:tock, :volume => 9)
      assert Cell::Rails.cache_store.write(key, 'ONE!')
   
      MusicianController.new.expire_cell_state(DirectorCell, :tock, :volume => 9)
      assert_equal "1", @class.cache_store.read(@key)
      assert_not ::Cell::Rails.cache_store.read(key)
    end
    
    should "raise a deprecation notice when passing in a :symbol" do
      assert_deprecated do
        MusicianController.new.expire_cell_state(:director, :tock)
      end
      assert_not @class.cache_store.read(@key)
    end
  end
  
  
  context ".cache" do
    setup do
      @proc = Proc.new{}

      @parent = Class.new(@class)
      @child = Class.new(@parent)
      @sibbling = Class.new(@parent)
    end
    
    should "accept a state name, only" do
      @class.cache :count
      
      assert_not @class.version_procs[:count]
      assert_equal({}, @class.cache_options[:count])
    end
    
    should "accept state and cache options" do
      @class.cache :count, :expires_in => 10.minutes
      
      assert_not @class.version_procs[:count]
      assert_equal({:expires_in => 10.minutes}, @class.cache_options[:count])
    end
    
    should "accept args and versioner block" do
      @class.cache :count, :expires_in => 10.minutes do "v1" end

      assert_kind_of Proc, @class.version_procs[:count]
      assert_equal({:expires_in => 10.minutes}, @class.cache_options[:count])
    end
    
    should "stil accept a versioner proc, only" do
      @class.cache :count, @proc
      
      assert_equal @proc, @class.version_procs[:count]
      assert_equal({},    @class.cache_options[:count])
    end
    
    should "stil accept a versioner block" do
      @class.cache :count do "v1" end
      
      assert_kind_of Proc, @class.version_procs[:count]
      assert_equal({},    @class.cache_options[:count])
    end

    should "inherit caching configuration" do
      @parent.cache :inherited_cache_configuration

      assert @parent.version_procs.has_key?(:inherited_cache_configuration)
      assert @child.version_procs.has_key?(:inherited_cache_configuration)
    end

    should "not overwrite caching configuration in the parent class" do
      @child.cache :inherited_cache_configuration

      assert_not @parent.version_procs.has_key?(:inherited_cache_configuration)
      assert @child.version_procs.has_key?(:inherited_cache_configuration)
    end

    should "not overwrite caching configuration in a sibbling class" do
      @sibbling.cache :inherited_cache_configuration

      assert_not @child.version_procs.has_key?(:inherited_cache_configuration)
      assert @sibbling.version_procs.has_key?(:inherited_cache_configuration)
    end

    should "overwrite caching configuration in a child class" do
      @class.cache :inherited_cache_configuration
      @child.cache :inherited_cache_configuration, @proc

      assert_not @parent.version_procs[:inherited_cache_configuration]
      assert_equal @proc, @child.version_procs[:inherited_cache_configuration]
    end
  end
end

class CachingFunctionalTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods

  setup do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
    setup # from Cell::TestCase::TestMethods
    
    @cell   = cell(:director)
    @class  = @cell.class
  end
  
  context "turned off" do
    should "not invoke caching" do
      ::ActionController::Base.perform_caching = false
      
      assert_equal "1", @cell.render_state(:tock)
      assert_equal "2", @cell.render_state(:tock)
    end
  end  
  
  
  context "without options" do
    should "cache forever" do
      @class.cache :tock
      assert_equal "1", render_cell(:director, :tock)
      assert_equal "1", render_cell(:director, :tock)
    end
  end
  
  
  context "uncached states" do
    should "not cache at all" do
      @class.class_eval do
        def dictate
          @count ||= 0
          render :text => (@count += 1)
        end
      end
      
      assert_equal "1", @cell.render_state(:dictate)
      assert_equal "2", @cell.render_state(:dictate)
    end
  end
  
  context "with versioner" do
    setup do
      @class.class_eval do
        def count(i)
          render :text => i
        end
      end
    end
    
    should "compute the key with a block receiving state-args" do
      @class.cache :count do |cell, int|
        (int % 2)==0 ? {:count => "even"} : {:count => "odd"}
      end
      # example cache key: cells/director/count/count=odd
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end
    
    should "compute the key with an instance method" do
      @class.cache :count, :version
      @class.class_eval do
        private
        def version(int)
          (int % 2)==0 ? {:count => "even"} : {:count => "odd"}
        end
      end
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end
    
    should "allow returning strings, too" do
      @class.cache :count do |cell, int|
        (int % 2)==0 ? "even" : "odd"
      end
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end
    
    should "be able to use caching conditionally" do
      @class.cache :count, :if => proc { |cell, int| (int % 2) != 0 }
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "4", render_cell(:director, :count, 4)
    end
    
    should "cache conditionally with an instance method" do
      @class.cache :count, :if => :odd?
      @class.class_eval do
        def odd?(int)
          (int % 2) != 0
        end
      end
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "4", render_cell(:director, :count, 4)
    end
  end
end
