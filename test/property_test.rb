require "test_helper"

class PropertyTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    property :title

    def title
      super + "</b>"
    end
  end

  let (:song) { Struct.new(:title).new("<b>She Sells And Sand Sandwiches") }
  # ::property creates automatic accessor.
  it { SongCell.(song).title.must_equal "<b>She Sells And Sand Sandwiches</b>" }
end


class EscapedPropertyTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    include Escaped
    property :title
    property :artist

    def title(*)
      "#{super}</b>" # super + "</b>" still escapes, but this is Rails.
    end

    def raw_title
      title(escape: false)
    end
  end

  let (:song) { Struct.new(:title, :artist).new("<b>She Sells And Sand Sandwiches", Object) }

  # ::property escapes, everywhere.
  it { SongCell.(song).title.must_equal "&lt;b&gt;She Sells And Sand Sandwiches</b>" }
  # no escaping for non-strings.
  it { SongCell.(song).artist.must_equal Object }
  # no escaping when escape: false
  it { SongCell.(song).raw_title.must_equal "<b>She Sells And Sand Sandwiches</b>" }
end