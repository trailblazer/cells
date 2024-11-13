require 'test_helper'

class SongWithLayoutCell < Cell::ViewModel
  self.view_paths = ['test/fixtures']
  # include Cell::Erb

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
    "<b>Papertiger</b>"
  end
end

class SongWithLayoutOnClassCell < SongWithLayoutCell
  # inherit_views SongWithLayoutCell
  layout :merry

  def show
    render
  end

  def show_with_layout
    render layout: :happy
  end
end

class LayoutTest < Minitest::Spec
  # render show.haml calling method.
  # same context as content view as layout call method.
  it { assert_equal "Merry Xmas, <b>Papertiger</b>\n", SongWithLayoutCell.new(nil).show }

  # raises exception when layout not found!
  it { assert_raises(Cell::TemplateMissingError) { SongWithLayoutCell.new(nil).unknown } }

  # with ::layout.
  it { assert_equal "Merry Xmas, <b>Papertiger</b>\n", SongWithLayoutOnClassCell.new(nil).show }

  # with ::layout and :layout, :layout wins.
  it { assert_equal "Happy Friday!", SongWithLayoutOnClassCell.new(nil).show_with_layout }
end

module Comment
  class ShowCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']
    include Layout::External

    def show
      render + render
    end
  end

  class LayoutCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']
  end
end

class ExternalLayoutTest < Minitest::Spec
  it do
    result = Comment::ShowCell.new(nil, layout: Comment::LayoutCell, context: { beer: true }).()

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
      assert_equal "$layout.erb{$show.erb, {:beer=>true}\n$show.erb, {:beer=>true}\n, {:beer=>true}}\n", result
    else
      assert_equal "$layout.erb{$show.erb, {beer: true}\n$show.erb, {beer: true}\n, {beer: true}}\n", result
    end
  end

  # collection :layout
  it do
    result = Cell::ViewModel.cell("comment/show", collection: [Object, Module], layout: Comment::LayoutCell).()
    assert_equal "$layout.erb{$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n, nil}\n", result
  end
end
