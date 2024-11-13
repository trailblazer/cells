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

  class Index < Cell::ViewModel
    cache :show
    include Cache
  end

  it do
    assert_equal "1", Index.new(1).()
    assert_equal "1", Index.new(2).()
  end
end
