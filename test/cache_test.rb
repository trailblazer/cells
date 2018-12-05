require "test_helper"

# TODO: test caching without rails

class CacheTest < Minitest::Spec
  STORE = Class.new(Hash) do
    def fetch(key, options)
      self[key] || (block_given? ? self[key] = yield : nil)
    end

    def exist?(key, _options = nil)
      !!self[key]
    end
  end.new

  def with_cache_cleanup
    yield
    STORE.clear
  end

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

  describe "#call" do
    it "returns cached value after value cached" do
      with_cache_cleanup do
        Index.new(1).().must_equal("1")
        Index.new(2).().must_equal("1")
      end
    end
  end

  describe "#cached?" do
    it "returns cached value after value cached" do
      with_cache_cleanup do
        cell_1 = Index.new(1)
        cell_2 = Index.new(2)

        cell_1.cached?.must_equal(false)
        cell_1.()
        cell_1.cached?.must_equal(true)
        cell_2.cached?.must_equal(true)
      end
    end
  end
end

