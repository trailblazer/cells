require "test_helper"

class CacheTest < Minitest::Spec
  STORE = Class.new(Hash) do
    def fetch(key, options, &block)
      self[key] || self[key] = yield
    end
  end.new

  module Cache
    def show(*)
      "#{@model}"
    end

    def cache_store
      STORE
    end

    def has_changed?(*)
      @model < 3
    end
  end

  Template = ->(action, *args, **kwargs, &block) {
    Class.new(Cell::ViewModel) do
      cache action, *args, **kwargs, &block
      include Cache
    end
  }

  it "without any arguments" do
    Default = Template.(:show)

    _(Default.new(1).()).must_equal("1")
    _(Default.new(2).()).must_equal("1")
  end

  it "with specified version" do
    # Cache invalidation using version proc
    WithVersionArg = Template.(:show, ->(options) { options[:version] })

    _(WithVersionArg.new(1).(:show, version: 1)).must_equal("1")
    _(WithVersionArg.new(2).(:show, version: 1)).must_equal("1")

    _(WithVersionArg.new(3).(:show, version: 2)).must_equal("3")

    # Cache invalidation using version block
    WithVersionBlock = Template.(:show) { |options| options[:version] }

    _(WithVersionBlock.new(1).(:show, version: 1)).must_equal("1")
    _(WithVersionBlock.new(2).(:show, version: 1)).must_equal("1")

    _(WithVersionBlock.new(3).(:show, version: 2)).must_equal("3")
  end

  it "with conditional" do
    WithConditional = Template.(:show, if: :has_changed?)

    _(WithConditional.new(1).(:show)).must_equal("1")
    _(WithConditional.new(2).(:show)).must_equal("1")

    _(WithConditional.new(3).(:show)).must_equal("3")
  end

  it "forwards remaining options to cache store" do
    WithOptions = Class.new(Cell::ViewModel) do
      cache :show, if: :has_changed?, expires_in: 10, tags: ->(*args) { Hash(args.first)[:tags] }
      include Cache

      NEW_STORE = Class.new(Hash) do
        def fetch(key, options)
          value = self[key] || self[key] = yield
          [value, options]
        end
      end.new

      def cache_store
        NEW_STORE
      end
    end

    _(WithOptions.new(1).(:show)).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})
    _(WithOptions.new(2).(:show)).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})
    _(WithOptions.new(2).(:show, tags: [:a, :b])).must_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]})
  end
end
