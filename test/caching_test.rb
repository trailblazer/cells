# encoding: utf-8
require 'test_helper'

class DirectorCell < Cell::ViewModel
  attr_reader :count

  def initialize(*)
    super
    @count = 0
  end

  cache :tock

  def tock
    @count += 1
  end
end


class CachingUnitTest < MiniTest::Spec
  before :each do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
  end

  let (:director) { DirectorCell }
  let (:cellule) { DirectorCell.new(nil) }


  describe "::state_cache_key" do
    # accepts state name, only.
    it { director.state_cache_key(:count).must_equal "cells/director/count/" }

    # accepts hash as key parts
    if Cell.rails_version >= Gem::Version.new('4.0')
      it { director.state_cache_key(:count, b: 2, a: 1).must_equal "cells/director/count/b/2/a/1" }
    else
      it { director.state_cache_key(:count, b: 2, a: 1).must_equal "cells/director/count/a=1&b=2" }
    end

    # accepts array as key parts
    it { director.state_cache_key(:count, [1, 2, 3]).must_equal "cells/director/count/1/2/3" }

    # accepts string as key parts
    it { director.state_cache_key(:count, "1/2").must_equal "cells/director/count/1/2" }

    # accepts nil as key parts
    it { director.state_cache_key(:count, nil).must_equal "cells/director/count/" }
  end


  describe "#state_cached?" do
    # true for cached
    it { cellule.send(:state_cached?, :tock).must_equal true }

    # false otherwise
    it { cellule.send(:state_cached?, :sing).must_equal false }
  end


  describe "#cache?" do
    # true for cached
    it { cellule.cache?(:tock).must_equal true }

    # false otherwise
    it { cellule.cache?(:sing).must_equal false }

    describe "perform_caching turned off" do
      after do
        ::ActionController::Base.perform_caching = true
      end

      # always false
      it do
        ::ActionController::Base.perform_caching = false
        cellule.cache?(:sing).must_equal false
        cellule.cache?(:sing).must_equal false
      end
    end

    describe "#cache_store" do
      # rails cache store per default.
      it { cellule.cache_store.must_equal ActionController::Base.cache_store }
    end
  end


  # describe ".expire_cache_key" do
  #   before :each do
  #     @key = @class.state_cache_key(:tock)
  #     puts "====== key is #{@key}"
  #     assert_equal "1", render_cell(:director, :tock)
  #     assert_equal "1", @class.cache_store.read(@key)
  #   end

  #   it "delete the state from cache" do
  #     @class.expire_cache_key(@key)
  #     assert_not @class.cache_store.read(@key)
  #   end

  #   it "be available in controllers for sweepers" do
  #     MusicianController.new.expire_cell_state(DirectorCell, :tock)
  #     assert_not @class.cache_store.read(@key)
  #   end

  #   it "accept cache options" do
  #     key = @class.state_cache_key(:tock, :volume => 9)
  #     assert Cell::Rails.cache_store.write(key, 'ONE!')

  #     MusicianController.new.expire_cell_state(DirectorCell, :tock, :volume => 9)
  #     assert_equal "1", @class.cache_store.read(@key)
  #     assert_not ::Cell::Rails.cache_store.read(key)
  #   end
  # end
end


class CachingTest < MiniTest::Spec
  class DirectorCell < Cell::ViewModel
    def initialize(controller, counter=0)
      super
      @counter = counter
    end

    def show # public method.
      @counter
    end


    cache :utf8

    def utf8
      "æøå" # or any other UTF-8 string
    end
  end

  before :each do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
  end

  # let (:cell) { DirectorCell.new(nil) }
  def cellule(*args)
    DirectorCell.new(nil, *args)
  end

  # no caching when turned off.
  it do
    cellule.class.cache :show
    ActionController::Base.perform_caching = false

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "2"
  end

  # cache forever when no options.
  it do
    cellule.class.cache :show
    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
  end


  # no caching when state not configured.
  it do
    cellule.class.class_eval do
      def dictate
        @counter
      end
    end

    cellule(1).call(:dictate).must_equal "1"
    cellule(2).call(:dictate).must_equal "2"
  end

  # compute key with cell properties from #initialize.
  it do
    cellule.class.cache :show do
      @counter < 3 ? {:count => "<"} : {:count => ">"}
    end

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
    cellule(3).call.must_equal "3"
    cellule(4).call.must_equal "3"
  end

  # compute key with instance method
  it do
    cellule.class.cache :show, :version
    cellule.class.class_eval do
      def version
        @counter < 3 ? {:count => "<"} : {:count => ">"}
      end
    end

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
    cellule(3).call.must_equal "3"
    cellule(4).call.must_equal "3"
  end

  # allow returning strings for key
  it do
    cellule.class.cache :show do
      @counter < 3 ? "<" : ">"
    end

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
    cellule(3).call.must_equal "3"
    cellule(4).call.must_equal "3"
  end

  # allows conditional ifs.
  it do
    cellule.class.cache :show, if: lambda { @counter < 3 }

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
    cellule(3).call.must_equal "3"
    cellule(4).call.must_equal "4"
  end

  # allows conditional ifs with instance method.
  it do
    cellule.class.class_eval do
      cache :show, if: :smaller?

      def smaller?
        @counter < 3
      end
    end

    cellule(1).call.must_equal "1"
    cellule(2).call.must_equal "1"
    cellule(3).call.must_equal "3"
    cellule(4).call.must_equal "4"
  end


  unless ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 2 # bug in 3.2.
    describe "utf-8" do
      before do
        @key = cellule.class.state_cache_key(:utf8)
      end

      it "has the correct encoding when reading from cache" do
        assert_equal "UTF-8", cellule.call(:utf8).encoding.to_s
        assert_equal "UTF-8", cellule.cache_store.read(@key).encoding.to_s
      end
    end
  end

  # options are passed through to cache store.
  # :expires_in.
  # :tags => lambda { |one, two, three| "#{one},#{two},#{three}" }
  class CacheStore
    attr_reader :fetch_args

    def fetch(*args)
      @fetch_args = args
    end
  end

  it do
    cellule = self.cellule

    cellule.instance_eval do
      def cache_store;
        @cache_store ||= CacheStore.new;
      end
    end

    cellule.class.cache :show, expires_in: 1.minutes, tags: lambda { self.class.to_s }
    cellule.call
    cellule.cache_store.fetch_args.must_equal ["cells/caching_test/director/show/", {expires_in: 60, tags: "CachingTest::DirectorCell"}]
  end
end


class CachingInheritanceTest < CachingTest
  class DirectorCell < ::DirectorCell
    cache :show, :expires_in => 10.minutes do
      "v1"
    end
  end

  class DirectorsSonCell < DirectorCell
  end

  class DirectorsDaughterCell < ::DirectorCell
    cache :show, :expires_in => 9.minutes do
      "v2"
    end
  end

end
