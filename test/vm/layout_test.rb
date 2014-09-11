require 'test_helper'

class SongWithLayoutCell < Cell::ViewModel
  self.view_paths = ["test/vm/fixtures"]

  def show
    render layout: :xmas
  end

  def unknown
    render layout: :no_idea_what_u_mean
  end

  def ivar
    @title = "Carnage"
    render
  end

  def string
    "Right"
  end

private
  def title
    "Papertiger"
  end
end

class LayoutTest < MiniTest::Spec
  # render show.haml calling method.
  it { SongWithLayoutCell.new(nil).show.must_equal "Merry Xmas, Papertiger\n" }

  # raises exception when layout not found!
  it { assert_raises { SongWithLayoutCell.new(nil).show } }

  # same context as content view.
end