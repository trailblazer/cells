require "test_helper"

class CacheTest < Minitest::Spec
  STORE = Class.new(Hash) do
    def fetch(key, options, &block)
      value = self[key] || self[key] = yield
      [value, options]
    end
  end.new

  module InstanceMethods
    def show(*)
      "#{@model}"
    end

    def new(*)
      "#{@model}"
    end

    def has_changed?(*)
      @model < 3
    end
  end

  Component = ->(*args, store: STORE, **kwargs, &block) {
    Class.new(Cell::ViewModel) do
      cache :show, *args, **kwargs, &block
      cache :new

      define_method(:cache_store) { store }

      include InstanceMethods
    end
  }

  it "without any options" do
    WithoutOptions = Component.()

    _(WithoutOptions.new(1).()).must_equal(%{["1", {}]})
    _(WithoutOptions.new(2).()).must_equal(%{["1", {}]})
  end

  it "with specified version" do
    version = ->(options) { options[:version] }

    # Cache invalidation using version as a proc
    WithVersionArg = Component.(version)

    _(WithVersionArg.new(1).(:show, version: 1)).must_equal(%{["1", {}]})
    _(WithVersionArg.new(2).(:show, version: 1)).must_equal(%{["1", {}]})

    _(WithVersionArg.new(3).(:show, version: 2)).must_equal(%{["3", {}]})

    # Cache invalidation using version as a block
    WithVersionBlock = Component.(&version)

    _(WithVersionBlock.new(1).(:show, version: 1)).must_equal(%{["1", {}]})
    _(WithVersionBlock.new(2).(:show, version: 1)).must_equal(%{["1", {}]})

    _(WithVersionBlock.new(3).(:show, version: 2)).must_equal(%{["3", {}]})
  end

  it "with conditional" do
    WithConditional = Component.(if: :has_changed?)

    _(WithConditional.new(1).()).must_equal(%{["1", {}]})
    _(WithConditional.new(2).()).must_equal(%{["1", {}]})

    _(WithConditional.new(3).()).must_equal("3")
  end

  it "forwards additional options to the store" do
    WithOptions = Component.(if: :has_changed?, expires_in: 10, tags: ->(*args) { Hash(args.first)[:tags] })

    _(WithOptions.new(1).()).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})
    _(WithOptions.new(2).()).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})

    _(WithOptions.new(2).(:show, tags: [:a, :b])).must_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]})
  end

  it "generates different cache key per cell and per action" do
    store = Class.new(STORE.class).new

    CellOne = Component.(store: store, expires_in: 10)
    CellTwo = Component.(store: store, expires_in: 10)

    CellOne.new(1).(:new)
    CellOne.new(2).()
    CellTwo.new(3).()

    _(store).must_equal({
      "cache_test/cell_one/new/"=>"1",
      "cache_test/cell_one/show/"=>"2",
      "cache_test/cell_two/show/"=>"3"
    })
  end
end
