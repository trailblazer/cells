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
    # properties :title, :body

    def render(options={})
      if options.is_a?(Hash)
        options.reverse_merge!(:view => state_for_implicit_render)
      else
        options = {:view => options.to_s}
      end

      super
    end

  private
    def view_context
      self
    end

    def state_for_implicit_render()
      caller[1].match(/`(\w+)/)[1]
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
  end

class ViewModelTest < MiniTest::Spec
  # change constructor so we can test new(comment).title
  # cell.show
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
  end

  test "explicit #render with one arg" do
    #@cell = SongCell.build_for(@controller, :song => Song.new(:title => "Blindfold", :id => 1))
    #@cell.stats.must_equal "<h3>BLINDFOLD</h3>\n"
  end
end