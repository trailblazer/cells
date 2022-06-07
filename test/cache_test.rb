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

  Component = ->(*args, **kwargs, &block) {
    Class.new(Cell::ViewModel) do
      cache :show, *args, **kwargs, &block
      include Cache
    end
  }

  it "without any options" do
    WithoutOptions = Component.()

    _(WithoutOptions.new(1).()).must_equal("1")
    _(WithoutOptions.new(2).()).must_equal("1")
  end

  it "with specified version" do
    version = ->(options) { options[:version] }

    # Cache invalidation using version as a proc
    WithVersionArg = Component.(version)

    _(WithVersionArg.new(1).(:show, version: 1)).must_equal("1")
    _(WithVersionArg.new(2).(:show, version: 1)).must_equal("1")

    _(WithVersionArg.new(3).(:show, version: 2)).must_equal("3")

    # Cache invalidation using version as a block
    WithVersionBlock = Component.(&version)

    _(WithVersionBlock.new(1).(:show, version: 1)).must_equal("1")
    _(WithVersionBlock.new(2).(:show, version: 1)).must_equal("1")

    _(WithVersionBlock.new(3).(:show, version: 2)).must_equal("3")
  end

  it "with conditional" do
    WithConditional = Component.(if: :has_changed?)

    _(WithConditional.new(1).()).must_equal("1")
    _(WithConditional.new(2).()).must_equal("1")

    _(WithConditional.new(3).()).must_equal("3")
  end

  it "forwards remaining options to cache store" do
    WithOptions = Class.new(Cell::ViewModel) do
      cache :show, if: :has_changed?, expires_in: 10, tags: ->(*args) { Hash(args.first)[:tags] }
    ## We can use kwargs in the cache key filter
      # cache :new, expires_in: 10, tags: ->(*, my_tags:, **) { my_tags } # FIXME: allow this in Cells 5.
      include Cache

      CACHE_WITH_OPTIONS_STORE = Class.new(Hash) do
        def fetch(key, options)
          value = self[key] || self[key] = yield
          [value, options]
        end
      end.new

      def cache_store
        CACHE_WITH_OPTIONS_STORE
      end
    end

    _(WithOptions.new(1).()).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})
    _(WithOptions.new(2).()).must_equal(%{["1", {:expires_in=>10, :tags=>nil}]})
    _(WithOptions.new(2).(:show, tags: [:a, :b])).must_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]})

    # FIXME: allow this in Cells 5.
    # _(WithOptions.new(2).(:new, my_tags: [:a, :b])).must_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]})
  end

  it "forwards all arguments to renderer after cache hit" do
    SongCell = Class.new(Cell::ViewModel) do
      cache :show

      def show(type, title:, part:, **)
        "#{type} #{title} #{part}"
      end

      def cache_store
        STORE
      end
    end

    # cache miss for the first render
    _(SongCell.new.(:show, "Album", title: "IT", part: "1")).must_equal("Album IT 1")

    # cache hit for the second render
    _(SongCell.new.(:show, "Album", title: "IT", part: "1")).must_equal("Album IT 1")
  end
end
