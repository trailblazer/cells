require 'test_helper'

class Song < OpenStruct
  extend ActiveModel::Naming

  def persisted?
    true
  end

  def to_param
    id
  end
end

# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class
class Cell::Rails
  module ViewModel
    include Cell::OptionsConstructor
    include ActionView::Helpers::UrlHelper
    include ActionView::Context # this includes CompiledTemplates, too.
    # properties :title, :body

    def render(options={})
      if options.is_a?(Hash)
        options.reverse_merge!(:view => state_for_implicit_render)
      else
        options = {:view => options.to_s}
      end

      super
    end

    def call
      render implicit_state
    end

  private
    def view_context
      self
    end

    def state_for_implicit_render()
      caller[1].match(/`(\w+)/)[1]
    end

    def implicit_state
      controller_path.split("/").last
    end
  end
end

class SongCell < Cell::Rails
    include Cell::Rails::ViewModel

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

    class Lyrics < self
      def show
        render :lyrics
      end
    end

    class PlaysCell < self
    end
  end

class ViewModelTest < MiniTest::Spec
  # views :show, :create #=> wrap in render_state(:show, *)
  let (:cell) { SongCell.build_for(nil, :title => "Shades Of Truth") }

  it { cell.title.must_equal "Shades Of Truth" }
 end

class ViewModelIntegrationTest < ActionController::TestCase
  tests MusicianController

  #let (:song) { Song.new(:title => "Blindfold", :id => 1) }
  #let (:html) { %{<h1>Shades Of Truth</h1>\n} }
  #let (:cell) {  }

  setup do
    @cell = SongCell.build_for(@controller, :song => Song.new(:title => "Blindfold", :id => 1))
  end

  test "URL helpers in view" do
    @cell.show.must_equal %{<h1>BLINDFOLD</h1>
<a href=\"/songs/1\">Permalink</a>
} end

  test "URL helper in instance" do
    @cell.self_url.must_equal "/songs/1"
  end

  test "implicit #render" do
    @cell.details.must_equal "<h3>BLINDFOLD</h3>\n"
    SongCell.build_for(@controller, :song => Song.new(:title => "Blindfold", :id => 1)).details
  end

  test "explicit #render with one arg" do
    @cell = SongCell.build_for(@controller, :song => Song.new(:title => "Blindfold", :id => 1))
    @cell.stats.must_equal "<h3>BLINDFOLD</h3>\n"
  end

  test "nested render" do
    @cell.info.must_equal "<li>BLINDFOLD\n</li>\n"
  end

  test "nested rendering method" do
    @cell.dashboard.must_equal "<h1>Dashboard</h1>\n<h3>Lyrics for BLINDFOLD</h3>\n<li>\nIn the Mirror\n</li>\n<li>\nI can see\n</li>\n\nPlays: 99\n\nPlays: 99\n\n"
  end

  # TODO: when we don't pass :song into Lyrics
end