# -*- coding: utf-8 -*-
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

  cache :utf8
  def utf8
    render :text => "æøå" # or any other UTF-8 string
  end
end

class CachingUnitTest < MiniTest::Spec
  include Cell::TestCase::TestMethods
  
  before :each do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
    @cell   = cell(:director)
    @class  = @cell.class
  end
  
  
  describe ".state_cache_key" do
    it "accept state only" do
      assert_equal "cells/director/count/", @class.state_cache_key(:count)
    end
    
    it "accept hash as key parts" do
      if Cell.rails4_0_or_more?
        assert_equal "cells/director/count/b/2/a/1", @class.state_cache_key(:count, :b=>2, :a=>1)
      else
        assert_equal "cells/director/count/a=1&b=2", @class.state_cache_key(:count, :b=>2, :a=>1)
      end
    end
    
    it "accept array as key parts" do
      assert_equal "cells/director/count/1/2/3", @class.state_cache_key(:count, [1,2,3])
    end
    
    it "accept string as key parts" do
      assert_equal "cells/director/count/1/2", @class.state_cache_key(:count, "1/2")
    end
    
    it "accept nil as key parts" do
      assert_equal "cells/director/count/", @class.state_cache_key(:count, nil)
    end
  end
  
  
  describe "#state_cached?" do
    it "return true for cached" do
      assert @cell.send :state_cached?, :tock
    end
    
    it "return false otherwise" do
      assert_not @cell.send :state_cached?, :sing
    end
  end
  
  
  describe "#cache?" do
    it "return true for cached" do
      assert @cell.cache?(:tock)
    end
    
    it "return false otherwise" do
      assert_not @cell.cache?(:sing)
    end
    
    describe "perform_caching turned off" do
      after :each do
        ::ActionController::Base.perform_caching = true
      end
      
      it "always return false if caching turned-off" do
        ::ActionController::Base.perform_caching = false
        assert_not @cell.cache?(:count)
        assert_not @cell.cache?(:sing)
      end
    end
    
    describe ".cache_store" do
      it "return Rails cache store per default" do
        assert_equal ActionController::Base.cache_store, DirectorCell.cache_store
      end
      
      describe "Cell::Base" do
        before :each do
          @class  = Class.new(Cell::Base)
          @cell   = @class.new
        end
        
        describe "#cache_store" do
          it "be setable from the outside" do
            assert_equal nil, @cell.cache_store
            @cell.cache_store = Object
            assert_equal Object, @cell.cache_store
          end
        end
        
        describe "#cache_configured?" do
          it "be setable from the outside" do
            assert_equal nil, @cell.cache_configured?
            @cell.cache_configured = true
            assert_equal true, @cell.cache_configured?
          end
        end
        
      end
    end
  end
  
  
  describe ".expire_cache_key" do
    before :each do
      @key = @class.state_cache_key(:tock)
      assert_equal "1", render_cell(:director, :tock)
      assert_equal "1", @class.cache_store.read(@key)
    end
    
    it "delete the state from cache" do
      @class.expire_cache_key(@key)
      assert_not @class.cache_store.read(@key)
    end
    
    it "be available in controllers for sweepers" do
      MusicianController.new.expire_cell_state(DirectorCell, :tock)
      assert_not @class.cache_store.read(@key)
    end
    
    it "accept cache options" do
      key = @class.state_cache_key(:tock, :volume => 9)
      assert Cell::Rails.cache_store.write(key, 'ONE!')
   
      MusicianController.new.expire_cell_state(DirectorCell, :tock, :volume => 9)
      assert_equal "1", @class.cache_store.read(@key)
      assert_not ::Cell::Rails.cache_store.read(key)
    end
    
    include ActiveSupport::Testing::Deprecation
    it "raise a deprecation notice when passing in a :symbol" do
      assert_deprecated do
        MusicianController.new.expire_cell_state(:director, :tock)
      end
      assert_not @class.cache_store.read(@key)
    end
  end
  
  
  describe ".cache" do
    let (:proc) { Proc.new {} }
    let (:parent) { Class.new(Cell::Base) }
    let (:brother) { Class.new(parent) }
    let (:sister) { Class.new(parent) }
    
    it "accept a state name, only" do
      @class.cache :count
      
      assert_not @class.version_procs[:count]
      assert_equal({}, @class.cache_options[:count])
    end
    
    it "accept state and cache options" do
      @class.cache :count, :expires_in => 10.minutes
      
      assert_not @class.version_procs[:count]
      assert_equal({:expires_in => 10.minutes}, @class.cache_options[:count])
    end
    
    it "accept args and versioner block" do
      @class.cache :count, :expires_in => 10.minutes do "v1" end

      assert_kind_of Proc, @class.version_procs[:count]
      assert_equal({:expires_in => 10.minutes}, @class.cache_options[:count])
    end
    
    it "stil accept a versioner proc, only" do
      @class.cache :count, proc
      
      assert_equal proc, @class.version_procs[:count]
      assert_equal({},    @class.cache_options[:count])
    end
    
    it "stil accept a versioner block" do
      @class.cache :count do "v1" end
      
      assert_kind_of Proc, @class.version_procs[:count]
      assert_equal({},    @class.cache_options[:count])
    end

    it "inherit caching configuration" do
      parent.cache :inherited_cache_configuration

      assert parent.version_procs.has_key?(:inherited_cache_configuration)
      assert brother.version_procs.has_key?(:inherited_cache_configuration)
    end

    it "not overwrite caching configuration in the parent class" do
      brother.cache :inherited_cache_configuration

      puts parent.version_procs.inspect
      assert ! parent.version_procs.has_key?(:inherited_cache_configuration)
      assert brother.version_procs.has_key?(:inherited_cache_configuration)
    end

    it "not overwrite caching configuration in a sibbling class" do
      sister.cache :inherited_cache_configuration

      assert ! brother.version_procs.has_key?(:inherited_cache_configuration)
      assert sister.version_procs.has_key?(:inherited_cache_configuration)
    end

    it "overwrite caching configuration in a child class" do
      @class.cache :inherited_cache_configuration
      brother.cache :inherited_cache_configuration, proc

      assert ! parent.version_procs[:inherited_cache_configuration]
      assert_equal proc, brother.version_procs[:inherited_cache_configuration]
    end
  end
end

class CachingFunctionalTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  before :each do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
    #setup # from Cell::TestCase::TestMethods
    
    @cell   = cell(:director)
    @class  = @cell.class
  end
  
  describe "turned off" do
    it "not invoke caching" do
      ::ActionController::Base.perform_caching = false
      
      assert_equal "1", @cell.render_state(:tock)
      assert_equal "2", @cell.render_state(:tock)
    end
  end  
  
  
  describe "without options" do
    it "cache forever" do
      @class.cache :tock
      assert_equal "1", render_cell(:director, :tock)
      assert_equal "1", render_cell(:director, :tock)
    end
  end
  
  
  describe "uncached states" do
    it "not cache at all" do
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
  
  describe "with versioner" do
    before do
      @class.class_eval do
        def count(i)
          render :text => i
        end
      end
    end
    
    it "compute the key with a block receiving state-args" do
      @class.cache :count do |cell, int|
        (int % 2)==0 ? {:count => "even"} : {:count => "odd"}
      end
      # example cache key: cells/director/count/count=odd
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end
    
    it "compute the key with an instance method" do
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
    
    it "allow returning strings, too" do
      @class.cache :count do |cell, int|
        (int % 2)==0 ? "even" : "odd"
      end
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end
    
    it "be able to use caching conditionally" do
      @class.cache :count, :if => proc { |cell, int| (int % 2) != 0 }
      
      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "4", render_cell(:director, :count, 4)
    end
    
    it "cache conditionally with an instance method" do
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
    
    it "allow using a different cache store" do
      class BassistCell < Cell::Base
        cache :play
        
        def play(song)
          render :text => song
        end
      end
      
      @cell = BassistCell.new
      
      assert_equal "New Years", @cell.render_state(:play, "New Years")
      assert_equal "Liar", @cell.render_state(:play, "Liar")
      
      @cell.cache_configured  = true
      @cell.cache_store       = ActiveSupport::Cache::MemoryStore.new
      
      assert_equal "New Years", @cell.render_state(:play, "New Years")
      assert_equal "New Years", @cell.render_state(:play, "Liar")
    end
  end

  describe "utf-8" do
    before do
      @key = @class.state_cache_key(:utf8)
    end

    it "have the correct encoding when reading from cache" do
      assert_equal "UTF-8", render_cell(:director, :utf8).encoding.to_s
      assert_equal "UTF-8", @class.cache_store.read(@key).encoding.to_s
    end
  end
end
