require "test_helper"

class FormForTestTest < MiniTest::Spec
  include Cell::Testing
  controller SongsController # provides #url_options.

  it do
    cell("formtastic").().gsub(/\s\s/, "").must_equal %{<form novalidate=\"novalidate\" class=\"formtastic song\" id=\"edit_song_1\" action=\"/songs/1\" accept-charset=\"UTF-8\" method=\"post\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input type=\"hidden\" name=\"_method\" value=\"patch\" /> First <li class=\"string input required stringish\" id=\"song_id_input\"><label for=\"song_id\" class=\"label\">Id<abbr title=\"required\">*</abbr></label><input id=\"song_id\" type=\"text\" value=\"1\" name=\"song[id]\" /></li><li class=\"string input required stringish\" id=\"song_artist_id_input\"><label for=\"song_artist_id\" class=\"label\">Id<abbr title=\"required\">*</abbr></label><input id=\"song_artist_id\" type=\"text\" name=\"song[artist][id]\" /></li><fieldset class=\"actions\"><ol> <input type=\"submit\" name=\"commit\" value=\"Go!\" as=\"button\" class=\"btn btn-primary\" />
</ol></fieldset>
</form>}
  end
end