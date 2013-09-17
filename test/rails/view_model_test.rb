require 'test_helper'

class Song < OpenStruct
  extend ActiveModel::Naming

  def persisted?
    false
  end
end

# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
class Cell::Rails
  module ViewModel
    include Cell::OptionsConstructor
    include ActionView::Helpers::UrlHelper
    # properties :title, :body
    # states :show, :next

  def initialize(*)
    super
    singleton_class.instance_eval do
      define_method :show do |*args|
        @_action_name = :show
        super(*args)
      end
    end
  end

  private
    def view_context
      self
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
  end

class ViewModelTest < MiniTest::Spec

  # change constructor so we can test new(comment).title
  # cell.show
  # views :show, :create #=> wrap in render_state(:show, *)
  include Cell::TestCase::TestMethods


  let (:cell) { SongCell.build_for(nil, :title => "Shades Of Truth") }

  it { cell.title.must_equal "Shades Of Truth" }
 end

class ViewModelIntegrationTest < ActionController::TestCase
  tests MusicianController

  #let (:song) { Song.new(:title => "Blindfold", :id => 1) }
  #let (:html) { %{<h1>Shades Of Truth</h1>\n} }
  #let (:cell) {  }

  test "" do SongCell.build_for(@controller, :song => Song.new(:title => "Blindfold", :id => 1)).show.must_equal %{<h1>BLINDFOLD</h1>
<a href=\"/songs\">Permalink</a>
} end
end