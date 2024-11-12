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
  it { _(SongWithLayoutCell.new(nil).show).must_equal "Merry Xmas, <b>Papertiger</b>\n" }

  # raises exception when layout not found!

  it { assert_raises(Cell::TemplateMissingError) { SongWithLayoutCell.new(nil).unknown } }
  # assert message of exception.
  it {  }

  # with ::layout.
  it { _(SongWithLayoutOnClassCell.new(nil).show).must_equal "Merry Xmas, <b>Papertiger</b>\n" }

  # with ::layout and :layout, :layout wins.
  it { _(SongWithLayoutOnClassCell.new(nil).show_with_layout).must_equal "Happy Friday!" }
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
      _(result).must_equal "$layout.erb{$show.erb, {:beer=>true}\n$show.erb, {:beer=>true}\n, {:beer=>true}}\n"
    else
      _(result).must_equal "$layout.erb{$show.erb, {beer: true}\n$show.erb, {beer: true}\n, {beer: true}}\n"
    end
  end

  # collection :layout
  it do
    _(Cell::ViewModel.cell("comment/show", collection: [Object, Module], layout: Comment::LayoutCell).()).
      must_equal "$layout.erb{$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n, nil}
"
  end
end
