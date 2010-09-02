# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DirectorCell < Cell::Rails
  cache :count
  
  @@counter = 0
  cattr_accessor :counter
  
  def self.increment!
    @@counter += 1
  end
  
  def self.reset!
    @@counter = 0
  end
  
  def increment!
    self.class.increment!
  end
  
  def count
    render :text => increment!
  end 
end

class CachingTest < ActiveSupport::TestCase
  context "The DirectorCell" do
    setup do
      DirectorCell.reset!
    end
    
    should "respond to #increment" do
      assert_equal 0, DirectorCell.counter
      assert_equal 1, DirectorCell.increment!
      assert_equal 1, DirectorCell.counter
    end
  end
  
  context "A cell" do
    setup do
      ::ActionController::Base.cache_store = :memory_store
      ::ActionController::Base.perform_caching = true
      DirectorCell.reset!
    end
    
    should "respond to state_cached?" do
      assert cell(:director).state_cached?(:count)
      assert_not cell(:director).state_cached?(:sing)
    end
    
    context "caching a state" do
      setup do
        @proc = Proc.new{}
      end
      
      should "save the version proc" do
        DirectorCell.cache :count, @proc
        
        assert_equal @proc, cell(:director).class.version_procs[:count]
        assert_equal({}, cell(:director).class.cache_options[:count])
      end
      
      should "save the cache options" do
        DirectorCell.cache :count, @proc, :expires_in => 10.minutes

        assert_equal @proc, cell(:director).class.version_procs[:count]
        assert_equal({:expires_in => 10.minutes}, cell(:director).class.cache_options[:count])
      end
      
      should "not mix caching configuration with other classes" do
        DirectorCell.cache :count
        class SecondDirectorCell < DirectorCell; end
        SecondDirectorCell.cache :count, @proc
        
        assert_equal nil, cell(:director).class.version_procs[:count]
        assert_equal @proc, cell(:"caching_test/second_director").class.version_procs[:count]
      end
    end
    
    context "caching without options" do
      setup do
        key = cell(:director).cache_key(:count, :count => 0)
        Cell::Base.expire_cache_key(key)  ### TODO: separate test
      end
      
      should "cache forever" do
        DirectorCell.class_eval do
          cache :count
        end
        
        assert cell(:director).state_cached?(:count)
        assert_equal nil, cell(:director).class.version_procs[:count]
        assert_equal({}, cell(:director).class.cache_options[:count])
        
        assert_equal render_cell(:director, :count), render_cell(:director, :count)
      end
      
      should "not cache at all" do
        DirectorCell.class_eval do
          def dictate
            render :text => increment!
          end
        end
        
        assert_equal "1", render_cell(:director, :dictate)
        assert_equal "2", render_cell(:director, :dictate)
      end
      
      should "expire the cache with a version proc" do
        DirectorCell.class_eval do
          cache :count, Proc.new { |cell|
            cell.class.counter >= 2 ? {:count => 2} : {:count => 0}
          }
          
          def count
            render :text => increment!
          end 
        end
        DirectorCell.reset!
        
        assert_equal "1", render_cell(:director, :count)
        assert_equal "1", render_cell(:director, :count)  # cached.
        
        DirectorCell.counter = 2  # invalidates the view cache.
        assert_equal "3", render_cell(:director, :count)
        assert_equal "3", render_cell(:director, :count)  # cached.
      end
      
      should "expire the cache with an instance method" do
        DirectorCell.class_eval do
          cache :count, :expire_count
          
          def expire_count
            self.class.counter >= 2 ? {:count => 2} : {:count => 0}
          end
          
          def count
            render :text => increment!
          end 
        end
        DirectorCell.reset!
        
        assert_equal "1", render_cell(:director, :count)
        assert_equal "1", render_cell(:director, :count)  # cached.
        
        DirectorCell.counter = 2  # invalidates the view cache.
        assert_equal "3", render_cell(:director, :count)
        assert_equal "3", render_cell(:director, :count)  # cached.
      end
    end
  end

  context "cache_key" do
    setup do
      @cell = cell(:director)
    end
    
    should "respond to cache_key" do
      assert_equal "cells/director/count", @cell.cache_key(:count)
      assert_equal @cell.cache_key(:count), ::Cell::Base.cache_key_for(:director, :count)
    end
    
    should "order options lexically" do
      assert_equal "cells/director/count/a=1/b=2", @cell.cache_key(:count, :b => 2, :a => 1)
    end
  end
  
  context "expire_cache_key" do
    setup do
      DirectorCell.class_eval do
        cache :count
        def count
          render :text => increment!
        end
      end
      DirectorCell.reset!
      
      @key = cell(:director).cache_key(:count)
      render_cell(:director, :count)
      assert_equal "1", ::Cell::Base.cache_store.read(@key)
    end
    
    should "delete the view from cache" do
      ::Cell::Base.expire_cache_key(@key)
      assert_not ::Cell::Base.cache_store.read(@key)
    end
    
    should "be available in controllers for sweepers" do
      MusicianController.new.expire_cell_state(:director, :count)
      assert_not ::Cell::Base.cache_store.read(@key)
    end
    
    should "accept cache options" do
      key = cell(:director).cache_key(:count, :volume => 9)
      assert ::Cell::Base.cache_store.write(key, 'ONE!')
   
      MusicianController.new.expire_cell_state(:director, :count, :volume => 9)
      assert_not ::Cell::Base.cache_store.read(key)
    end
  end
end
