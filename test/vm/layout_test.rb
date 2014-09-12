require 'test_helper'

class SongWithLayoutCell < Cell::ViewModel
  self.view_paths = ["test/vm/fixtures"]

  def show
    render layout: :merry
  end

  def unknown
    render layout: :no_idea_what_u_mean
  end

  def what
    "Xmas"
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
  # same context as content view as layout call method.
  it { SongWithLayoutCell.new(nil).show.must_equal "Merry Xmas, Papertiger\n" }

  # raises exception when layout not found!

  it { assert_raises(Cell::TemplateMissingError) { SongWithLayoutCell.new(nil).unknown } }
  # assert message of exception.
  it {  }
end