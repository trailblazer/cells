require 'test_helper'
require 'cells/song_with_layout_on_class_cell'

class LayoutTest < MiniTest::Spec
  # render show.haml calling method.
  # same context as content view as layout call method.
  it { SongWithLayoutCell.new(nil).show.must_equal "Merry Xmas, <b>Papertiger</b>\n" }

  # raises exception when layout not found!

  it { assert_raises(Cell::TemplateMissingError) { SongWithLayoutCell.new(nil).unknown } }
  # assert message of exception.
  it {  }

  # with ::layout.
  it { SongWithLayoutOnClassCell.new(nil).show.must_equal "Merry Xmas, <b>Papertiger</b>\n" }

  # with ::layout and :layout, :layout wins.
  it { SongWithLayoutOnClassCell.new(nil).show_with_layout.must_equal "Happy Friday\n!\n" }
end