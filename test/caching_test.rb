# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[test_helper])

class CachingCell < ::Cell::Base
  cache :cached_state

  def cached_state
    count = controller.session[:cache_count]
    count ||= 0
    count += 1
    "#{count} should remain the same forever!"
  end

  def not_cached_state
    "i'm really static"
  end

  cache :versioned_cached_state, Proc.new { |cell|
    if (v = cell.session[:version]) > 0
      {:version => v}
    else
      {:version => 0}
    end
  }
  def versioned_cached_state
    "#{session[:version].inspect} should change every third call!"
  end

  def my_version_proc
    if (v = session[:version]) > 0
      {:version => v}
    else
      {:version => 0}
    end
  end

  # def cached_state_with_symbol_proc
  # end

  cache :cheers
  def cheers
    'cheers!'
  end

  cache :another_state
  def another_state
    @opts[:str]
  end
end

class AnotherCachingCell < ::Cell::Base
  cache :cheers
  def cheers
    'prost!'
  end

  def another_state
    @opts[:str]
  end
end

class CachingTest < ActiveSupport::TestCase
  def setup
    super
    @controller.session = {}
    @cc = CachingCell.new(@controller)
    @c2 = AnotherCachingCell.new(@controller)

    @old_action_controller_cache_store = ::ActionController::Base.cache_store
    @old_action_controller_perform_caching = ::ActionController::Base.perform_caching
    ::ActionController::Base.cache_store = :memory_store
    ::ActionController::Base.perform_caching = true
    
    ### FIXME: sorry for that, but we need to force caching. avoid #alias_method_chain.
    Cell::Base.alias_method_chain :render_state, :caching unless Cell::Base.method_defined? :render_state_without_caching
  end

  def teardown
    ::ActionController::Base.cache_store = @old_action_controller_cache_store
    ::ActionController::Base.perform_caching = @old_action_controller_perform_caching
  end

  def test_state_cached?
    assert @cc.state_cached?(:cached_state)
    assert_not @cc.state_cached?(:not_cached_state)
  end

  def test_cache_without_options
    # :cached_state is cached without any options:
    assert_nil @cc.version_procs[:cached_state]
    assert_nil @cc.version_procs[:not_cached_state]

    # cache_options must at least return an empty hash for a cached state:
    assert_equal ({}), @cc.cache_options[:cached_state]
    assert_nil @cc.cache_options[:not_cached_state]
  end

  def test_cache_with_proc_only
    CachingCell.class_eval do
      cache :my_state, Proc.new {}
    end

    assert_kind_of Proc, @cc.version_procs[:my_state]
    assert_equal ({}), @cc.cache_options[:my_state]
  end

  def test_cache_with_proc_and_cache_options
    CachingCell.class_eval do
      cache :my_state, Proc.new{}, {:expires_in => 10.seconds}
    end

    assert_kind_of Proc, @cc.version_procs[:my_state]
    assert_equal ({:expires_in => 10.seconds}), @cc.cache_options[:my_state]
  end

  def test_cache_with_cache_options_only
    CachingCell.class_eval do
      cache :my_state, :expires_in => 10.seconds
    end

    assert @cc.version_procs.has_key?(:my_state)
    assert_nil @cc.version_procs[:my_state]
    assert_equal ({:expires_in => 10.seconds}), @cc.cache_options[:my_state]
  end

  def test_if_caching_works
    c = @cc.render_state(:cached_state)
    assert_equal "1 should remain the same forever!", c

    c = @cc.render_state(:cached_state)
    assert_equal "1 should remain the same forever!", c, ":cached_state was invoked again"
  end

  def test_cache_key
    assert_equal "cells/caching/some_state", @cc.cache_key(:some_state)
    assert_equal @cc.cache_key(:some_state), ::Cell::Base.cache_key_for(:caching, :some_state)
    assert_equal "cells/caching/some_state/param=9", @cc.cache_key(:some_state, :param => 9)
    assert_equal "cells/caching/some_state/a=1/b=2", @cc.cache_key(:some_state, :b => 2, :a => 1)
  end

  def test_render_state_without_caching
    c = @cc.render_state(:not_cached_state)
    assert_equal "i'm really static", c

    c = @cc.render_state(:not_cached_state)
    assert_equal "i'm really static", c
  end

  def test_caching_with_version_proc
    @controller.session[:version] = 0
    # render state, as it's not cached:
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '0 should change every third call!', c

    @controller.session[:version] = -1
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '0 should change every third call!', c

    @controller.session[:version] = 1
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '1 should change every third call!', c

    @controller.session[:version] = 2
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '2 should change every third call!', c

    @controller.session[:version] = 3
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '3 should change every third call!', c
  end

  def test_caching_with_instance_version_proc
    CachingCell.class_eval do
      cache :versioned_cached_state, :my_version_proc
    end

    @controller.session[:version] = 0
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '0 should change every third call!', c

    @controller.session[:version] = 1
    c = @cc.render_state(:versioned_cached_state)
    assert_equal '1 should change every third call!', c
  end

  def test_caching_with_two_same_named_states
    c = @cc.render_state(:cheers)
    assert_equal 'cheers!', c

    c = @c2.render_state(:cheers)
    assert_equal 'prost!', c

    c = @cc.render_state(:cheers)
    assert_equal 'cheers!', c

    c = @c2.render_state(:cheers)
    assert_equal 'prost!', c
  end

  def test_caching_one_of_two_same_named_states
    ### DISCUSS with drogus: the problem was that CachingCell and AnotherCachingCell keep
    ### overwriting their version_procs, wasn't it? why don't we test that with different
    ### version_procs in each cell?
    @cc = CachingCell.new(@controller, :str => 'foo1')
    c = @cc.render_state(:another_state)
    assert_equal 'foo1',c

    @c2 = AnotherCachingCell.new(@controller, :str => 'foo2')
    c = @c2.render_state(:another_state)
    assert_equal 'foo2', c

    @cc = CachingCell.new(@controller, :str => 'bar1')
    c = @cc.render_state(:another_state)
    assert_equal 'foo1', c

    @c2 = AnotherCachingCell.new(@controller, :str => 'bar2')
    c = @c2.render_state(:another_state)
    assert_equal 'bar2', c
  end

  def test_expire_cache_key
    key = @cc.cache_key(:cached_state)
    @cc.render_state(:cached_state)
    assert ::Cell::Base.cache_store.read(key)

    ::Cell::Base.expire_cache_key(key)
    assert_not ::Cell::Base.cache_store.read(key)

    # test via ActionController::expire_cell_state, which is called from Sweepers.
    @cc.render_state(:cached_state)
    assert ::Cell::Base.cache_store.read(key)

    @controller.expire_cell_state(:caching, :cached_state)
    assert_not ::Cell::Base.cache_store.read(key)

    # ..and additionally test if passing cache key args works:
    key = @cc.cache_key(:cached_state, :more => :yes)
    assert ::Cell::Base.cache_store.write(key, 'test content')

    @controller.expire_cell_state(:caching, :cached_state, :more => :yes)
    assert_not ::Cell::Base.cache_store.read(key)
  end

  def test_find_family_view_for_state_with_caching
    # test environment: --------------------------------------
    assert_equal ({}), ACell.state2view_cache

    cell = ACell.new(@controller)
    cell.class.instance_eval do
      def cache_configured?
        false
      end
    end
    cell.render_state :existing_view
    # in development/test environment, no view name caching should happen,
    # if perform_caching is false.
    assert_equal ({}), ACell.state2view_cache

    # production environment: --------------------------------
    cell = ACell.new(@controller)
    cell.class.instance_eval do
      def cache_configured?
        true
      end
    end
    
    cell.render_state :existing_view
    assert ACell.state2view_cache.has_key?("existing_view/html") 
  end
end
