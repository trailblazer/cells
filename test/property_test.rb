require "test_helper"

class PropertyTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    property :title

    def title
      super + "</b>"
    end
  end

  let (:song) { Struct.new(:title).new("<b>She Sells And Sand Sandwiches") }
  # ::property creates automatic accessor.
  it { _(SongCell.(song).title).must_equal "<b>She Sells And Sand Sandwiches</b>" }
end


class EscapedPropertyTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    include Escaped
    property :title
    property :artist
    property :copyright, :lyrics

    def title(*)
      "#{super}</b>" # super + "</b>" still escapes, but this is Rails.
    end

    def raw_title
      title(escape: false)
    end
  end

  let (:song) do
    Struct
      .new(:title, :artist, :copyright, :lyrics)
      .new("<b>She Sells And Sand Sandwiches", Object, "<a>Copy</a>", "<i>Words</i>")
  end

  # ::property escapes, everywhere.
  it { _(SongCell.(song).title).must_equal "&lt;b&gt;She Sells And Sand Sandwiches</b>" }
  it { _(SongCell.(song).copyright).must_equal "&lt;a&gt;Copy&lt;/a&gt;" }
  it { _(SongCell.(song).lyrics).must_equal "&lt;i&gt;Words&lt;/i&gt;" }
  # no escaping for non-strings.
  it { _(SongCell.(song).artist).must_equal Object }
  # no escaping when escape: false
  it { _(SongCell.(song).raw_title).must_equal "<b>She Sells And Sand Sandwiches</b>" }
end
