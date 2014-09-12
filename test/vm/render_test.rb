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

  def unknown
    render
  end

  def string
    "Right"
  end

  # TODO: just pass hash.
  def with_locals
    render locals: {length: 280, title: "Shot Across The Bow"}
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

  # call/render_state

  # throws an exception when not found.
  it do
    exception = assert_raises(Cell::TemplateMissingError) { SongCell.new(nil).unknown }
    exception.message.must_equal "Template missing: view: `unknown[.haml]` prefixes: [\"song\"] view_paths:[\"test/vm/fixtures\"]"
  end

  # allows locals
  it { SongCell.new(nil).with_locals.must_equal "Shot Across The Bow\n280\n" }
end

# test inheritance