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
      if Cell.rails_version >= ("4.0")
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
      puts "====== key is #{@key}"
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
      @class.cache :count do |int|
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

    it "allows returning strings, too" do
      @class.cache :count do |int|
        (int % 2)==0 ? "even" : "odd"
      end

      assert_equal "1", render_cell(:director, :count, 1)
      assert_equal "2", render_cell(:director, :count, 2)
      assert_equal "1", render_cell(:director, :count, 3)
      assert_equal "2", render_cell(:director, :count, 4)
    end

    it "be able to use caching conditionally" do
      @class.cache :count, :if => lambda { |int| (int % 2) != 0 }

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

  unless ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 2 # bug in 3.2.
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


  def cache_store(&block)
    Object.new.instance_eval do
      @block = block
      def fetch(key, options)
        @block.call(key, options)
      end
      self
    end
  end

  def cached(&block)
    cs = cache_store(&block)

    @cell.instance_eval do
      def count(*)
        "this should never be returned!"
      end

      @cache_store = cs
      def cache_store
        @cache_store
      end
    end

    @cell
  end

  # ::cache

  describe "with state name, only" do
    it do
      @class.cache :count

      cached do |key, options|
        if options == {} and key == "cells/director/count/"
          "cached!"
        end
      end.render_state(:count, 1, 2, 3).must_equal "cached!"
    end
  end

  describe "with cache store options" do
    it do
      @class.cache :count, :expires_in => 10.minutes

      cached do |key, options|
        if options == {:expires_in => 600}
          "cached!"
        end
      end.render_state(:count, 1, 2, 3).must_equal "cached!"
    end
  end

  describe "with versioner block" do
    it do
      @class.cache :count do "v3" end

      cached do |key, options|
        if options == {} and key == "cells/director/count/v3"
          "cached!"
        end
      end.render_state(:count).must_equal "cached!"
    end

    it "is executed in instance context" do
      @class.cache :count do version end

      @cell.instance_eval do
        def version; "v3"; end
      end

      cached do |key, options|
        if options == {} and key == "cells/director/count/v3"
          "cached!"
        end
      end.render_state(:count).must_equal "cached!"
    end
  end

  describe "with store options and versioner block" do
    it do
      @class.cache :count, :expires_in => 10.minutes do "v1" end

      cached do |key, options|
        if options == {:expires_in => 600} and key == "cells/director/count/v1"
          "cached!"
        end
      end.render_state(:count, 1, 2, 3).must_equal "cached!"
    end
  end

  describe "lambda and options as options" do
    it "runs lamda at render-time" do
      @class.cache :count, :expires_in => 9, :tags => lambda { |one, two, three| "#{one},#{two},#{three}" }

      cached do |key, options|
        if options == {:expires_in => 9, :tags => "1,2,3"}
          "cached!"
        end
      end.render_state(:count, 1, 2, 3).must_equal "cached!"
    end
  end
end


class CachingInheritanceTest < CachingFunctionalTest
  class DirectorCell < ::DirectorCell
    cache :count, :expires_in => 10.minutes do
      "v1"
    end
  end

  class DirectorsSonCell < DirectorCell
  end

  class DirectorsDaughterCell < ::DirectorCell
    cache :count, :expires_in => 9.minutes do
      "v2"
    end
  end

  it do
    @cell = DirectorCell.new(@controller)

    cached do |key, options|
      if options == {:expires_in => 600} and key == "cells/caching_inheritance_test/director/count/v1"
        "cached!"
      end
    end.render_state(:count).must_equal "cached!"
  end

  it do
    @cell = DirectorsDaughterCell.new(@controller)

    cached do |key, options|
      if options == {:expires_in => 540} and key == "cells/caching_inheritance_test/directors_daughter/count/v2"
        "cached!"
      end
    end.render_state(:count).must_equal "cached!"
  end

  it do
    @cell = DirectorsSonCell.new(@controller)

    cached do |key, options|
      if options == {:expires_in => 600} and key == "cells/caching_inheritance_test/directors_son/count/v1"
        "cached!"
      end
    end.render_state(:count).must_equal "cached!"
  end
end
