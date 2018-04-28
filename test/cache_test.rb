require "test_helper"

# TODO: test caching without rails

class CacheTest < Minitest::Spec
  STORE = Class.new(Hash) do
    def fetch(key, options, &block)
      self[key] || self[key] = yield
    end
  end.new

  module Cache
    def show
      "#{@model}"
    end

    def cache_store
      STORE
    end
  end

  class CacheableModel
    attr_accessor :id, :value, :timestamp

    def initialize(id, value, timestamp)
      @id = id
      @value = value
      @timestamp = timestamp
    end

    def cache_key
      [@id, @timestamp]
    end

    def to_s
      @value
    end
  end

  class Index < Cell::ViewModel
    cache :show
    include Cache
  end

  class CacheKeyedIndex < Cell::ViewModel
    cache :show do
      @model
    end
    include Cache
  end

  it do
    Index.new(1).().must_equal('1')
    Index.new(2).().must_equal('1')
  end

  it do
    # Both models cache differently due to unique ID/time combinations
    model_a = CacheableModel.new('id-1', 'abc', Time.now)
    model_b = CacheableModel.new('id-2', 'efg', Time.now)

    CacheKeyedIndex.new(model_a).().must_equal('abc')
    CacheKeyedIndex.new(model_b).().must_equal('efg')

    # Model A returns from cache as ID/time haven't updated
    model_a.value = 'xyz'

    CacheKeyedIndex.new(model_a).().must_equal('abc')

    # Model A should cache new value as the timestamp is now different
    model_a.timestamp = Time.local(2000, 1, 1)

    CacheKeyedIndex.new(model_a).().must_equal('xyz')
  end
end
