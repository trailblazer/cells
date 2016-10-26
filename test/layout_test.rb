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
  it { SongWithLayoutOnClassCell.new(nil).show_with_layout.must_equal "Happy Friday!" }
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
    include Cell::Builder

    builds { |_, context:, **| SpecialLayoutCell if context.to_h.fetch(:special_layout, false) }

    self.view_paths = ['test/fixtures']
  end

  class SpecialLayoutCell < LayoutCell
  end
end

class ExternalLayoutTest < Minitest::Spec
  it do
    Comment::ShowCell.new(nil, layout: Comment::LayoutCell, context: { beer: true }).
      ().must_equal "$layout.erb{Comment::LayoutCell, $show.erb, {:beer=>true}\n$show.erb, {:beer=>true}\n, {:beer=>true}}\n"
  end

  # collection :layout
  it do
    Cell::ViewModel.cell("comment/show", collection: [Object, Module], layout: Comment::LayoutCell).().
      must_equal "$layout.erb{Comment::LayoutCell, $show.erb, nil
$show.erb, nil
$show.erb, nil
$show.erb, nil
, nil}
"
  end

  it 'renders special layout if requested' do
    Comment::ShowCell.new(nil, layout: Comment::LayoutCell, context: { special_layout: true }).
      ().must_equal "$layout.erb{Comment::SpecialLayoutCell, $show.erb, {:special_layout=>true}
$show.erb, {:special_layout=>true}
, {:special_layout=>true}}
"
  end
end
