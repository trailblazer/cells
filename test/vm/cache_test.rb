require 'test_helper'

class CachingUnitTest < MiniTest::Spec
  # include Cell::TestCase::TestMethods

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

    cache :utf8
    def utf8
      "æøå" # or any other UTF-8 string
    end
  end

  before :each do
    ActionController::Base.cache_store.clear
    ActionController::Base.perform_caching = true
  end

  let (:director) { DirectorCell }
  let (:cell)     { DirectorCell.new(nil) }


  describe "::state_cache_key" do
    # accepts state name, only.
    it { director.state_cache_key(:count).must_equal "cells/caching_unit_test/director/count/" }

    # accepts hash as key parts
    if Cell.rails_version >= ("4.0")
      it { director.state_cache_key(:count, b: 2, a: 1).must_equal "cells/caching_unit_test/director/count/b/2/a/1" }
    else
      it { director.state_cache_key(:count, b: 2, a: 1).must_equal "cells/caching_unit_test/director/count/a=1&b=2" }
    end

    # accepts array as key parts
    it { director.state_cache_key(:count, [1,2,3]).must_equal "cells/caching_unit_test/director/count/1/2/3" }

    # accepts string as key parts
    it { director.state_cache_key(:count, "1/2").must_equal "cells/caching_unit_test/director/count/1/2" }

    # accepts nil as key parts
    it { director.state_cache_key(:count, nil).must_equal "cells/caching_unit_test/director/count/" }
  end


  describe "#state_cached?" do
    # true for cached
    it { cell.send(:state_cached?, :tock).must_equal true }

    # false otherwise
    it { cell.send(:state_cached?, :sing).must_equal false }
  end


  describe "#cache?" do
    # true for cached
    it { cell.cache?(:tock).must_equal true }

    # false otherwise
    it { cell.cache?(:sing).must_equal false }

    describe "perform_caching turned off" do
      after do
        ::ActionController::Base.perform_caching = true
      end

      # always false
      it do
        ::ActionController::Base.perform_caching = false
        cell.cache?(:sing).must_equal false
        cell.cache?(:sing).must_equal false
      end
    end

    describe "#cache_store" do
      # rails cache store per default.
      it { cell.cache_store.must_equal ActionController::Base.cache_store }
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