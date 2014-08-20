require 'test_helper'

if Cell.rails_version >= 3.1

  class Song < OpenStruct
    extend ActiveModel::Naming

    def persisted?
      true
    end

    def to_param
      id
    end
  end



  class SongCell < Cell::ViewModel
    def show
      render
    end

    def title
      song.title.upcase
    end

    def self_url
      url_for(song)
    end

    def details
      render
    end

    def stats
      render :details
    end

    def info
      render :info
    end

    def dashboard
      render :dashboard
    end

    def scale
      render :layout => 'b'
    end

    class Lyrics < self
      def show
        render :lyrics
      end
    end

    class PlaysCell < self
      def show
        render :plays
      end
    end
  end

  class ViewModelTest < MiniTest::Spec
    # views :show, :create #=> wrap in render_state(:show, *)
    let (:cell) { SongCell.new(nil, :title => "Shades Of Truth") }

    it { cell.title.must_equal "Shades Of Truth" }

    class HitCell < Cell::ViewModel
      property :title, :artist

      def show
        "Great!"
      end

      def rate
        "Fantastic!"
      end

      attr_accessor :count
      cache :count

      def title
        super.upcase
      end
    end

    let (:song) { Song.new(:title => "Sixtyfive", artist: "Boss") }

    # ::property creates accessor.
    it { HitCell.new(nil, song).artist.must_equal "Boss" }

    # ::property accessor can be overridden and call super.
    it { HitCell.new(nil, song).title.must_equal "SIXTYFIVE" }


    describe "#call" do
      let (:cell) { HitCell.new(nil, song) }

      it { cell.call.must_equal "Great!" }
      it { cell.call(:rate).must_equal "Fantastic!" }

      it "no caching" do
        cell.instance_eval do
          def cache_configured?
            false
          end
        end

        cell.count = 1
        cell.call(:count).must_equal "1"
        cell.count = 2
        cell.call(:count).must_equal "2"
      end

      it "with caching" do
        cell.instance_eval do
          self.cache_store = ActiveSupport::Cache::MemoryStore.new
          self.cache_configured = true
        end

        cell.count = 1
        cell.call(:count).must_equal "1"
        cell.count = 2
        cell.call(:count).must_equal "1"
      end

      # call(:show) do .. end
      it do
        cell.call(:show) do |c|
          c.instance_variable_set(:@volume, 9)
        end.must_equal "Great!"

        cell.instance_variable_get(:@volume).must_equal 9
      end
    end


    # describe "::helper" do
    #   it { assert_raises { HitCell.helper Module.new } }
    # end
  end


  if Cell.rails_version >= "3.2"
    class ViewModelIntegrationTest < ActionController::TestCase
      tests MusicianController

      #let (:song) { Song.new(:title => "Blindfold", :id => 1) }
      #let (:html) { %{<h1>Shades Of Truth</h1>\n} }
      #let (:cell) {  }

      setup do
        @cell = SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => "1"))

        @url = "/songs/1"
        @url = "http://test.host/songs/1" if Cell.rails_version.>=("4.0")
      end


      # test "instantiating without model, but call to ::property" do
      #   assert_raises do
      #     @controller.cell("view_model_test/piano_song")
      #   end
      # end


      test "URL helpers in view" do
          @cell.show.must_equal %{<h1>BLINDFOLD</h1>
<a href=\"#{@url}\">Permalink</a>
}     end

      test "URL helper in instance" do
        @cell.self_url.must_equal @url
      end

      test "implicit #render" do
        @cell.details.must_equal "<h3>BLINDFOLD</h3>\n"
        SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => 1)).details
      end

      test "explicit #render with one arg" do
        @cell = SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => 1))
        @cell.stats.must_equal "<h3>BLINDFOLD</h3>\n"
      end

      test "nested render" do
        @cell.info.must_equal "<li>BLINDFOLD\n</li>\n"
      end

      test "nested rendering method" do
        @cell.dashboard.must_equal "<h1>Dashboard</h1>\n<h3>Lyrics for BLINDFOLD</h3>\n<li>\nIn the Mirror\n</li>\n<li>\nI can see\n</li>\n\nPlays: 99\n\nPlays: 99\n\n"
      end

      test( "layout") { @cell.scale.must_equal "<b>A Minor!\n</b>" }

      # TODO: when we don't pass :song into Lyrics
    end
  end

  class CollectionTest < MiniTest::Spec
    class ReleasePartyCell < Cell::ViewModel
      def show
        "Party on, #{model}!"
      end

      def show_more
        "Go nuts, #{model}!"
      end
    end


    describe "::collection" do
      it { Cell::ViewModel.collection("collection_test/release_party", @controller, %w{Garth Wayne}).must_equal "Party on, Garth!\nParty on, Wayne!" }
      it { Cell::ViewModel.collection("collection_test/release_party", @controller, %w{Garth Wayne}, :show_more).must_equal "Go nuts, Garth!\nGo nuts, Wayne!" }
    end
    # TODO: test with builders ("polymorphic collections") and document that.

    describe "::cell" do
      it { Cell::ViewModel.cell("collection_test/release_party", @controller, "Garth").call.must_equal "Party on, Garth!" }
    end
  end

end