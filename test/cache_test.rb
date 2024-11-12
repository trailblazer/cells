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

    assert_equal("1", WithoutOptions.new(1).())
    assert_equal("1", WithoutOptions.new(2).())
  end

  it "with specified version" do
    version = ->(options) { options[:version] }

    # Cache invalidation using version as a proc
    WithVersionArg = Component.(version)

    assert_equal("1", WithVersionArg.new(1).(:show, version: 1))
    assert_equal("1", WithVersionArg.new(2).(:show, version: 1))

    assert_equal("3", WithVersionArg.new(3).(:show, version: 2))

    # Cache invalidation using version as a block
    WithVersionBlock = Component.(&version)

    assert_equal("1", WithVersionBlock.new(1).(:show, version: 1))
    assert_equal("1", WithVersionBlock.new(2).(:show, version: 1))

    assert_equal("3", WithVersionBlock.new(3).(:show, version: 2))
  end

  it "with conditional" do
    WithConditional = Component.(if: :has_changed?)

    assert_equal("1", WithConditional.new(1).())
    assert_equal("1", WithConditional.new(2).())

    assert_equal("3", WithConditional.new(3).())
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

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
      assert_equal(%{["1", {:expires_in=>10, :tags=>nil}]}, WithOptions.new(1).())
      assert_equal(%{["1", {:expires_in=>10, :tags=>nil}]}, WithOptions.new(2).())
      assert_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]}, WithOptions.new(2).(:show, tags: [:a, :b]))
    else
      assert_equal(%{["1", {expires_in: 10, tags: nil}]}, WithOptions.new(1).())
      assert_equal(%{["1", {expires_in: 10, tags: nil}]}, WithOptions.new(2).())
      assert_equal(%{["1", {expires_in: 10, tags: [:a, :b]}]}, WithOptions.new(2).(:show, tags: [:a, :b]))
    end

    # FIXME: allow this in Cells 5.
    # assert_equal(%{["1", {:expires_in=>10, :tags=>[:a, :b]}]}), WithOptions.new(2).(:new, my_tags: [:a, :b]))
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
    assert_equal("Album IT 1", SongCell.new.(:show, "Album", title: "IT", part: "1"))

    # cache hit for the second render
    assert_equal("Album IT 1", SongCell.new.(:show, "Album", title: "IT", part: "1"))
  end
end
