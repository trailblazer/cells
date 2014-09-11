require 'test_helper'

class SongCell < Cell::ViewModel
  self.view_paths = ["test/vm/fixtures"]

  def show
    render
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

class RenderTest < MiniTest::Spec
  # render show.haml calling method.
  it { SongCell.new(nil).show.must_equal "Papertiger\n" }

  # render ivar.haml using instance variable.
  it { SongCell.new(nil).ivar.must_equal "Carnage\n" }

  # render string.
  it { SongCell.new(nil).string.must_equal "Right" }
end