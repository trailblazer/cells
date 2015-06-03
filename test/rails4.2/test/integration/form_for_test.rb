require "test_helper"

class FormForTestTest < MiniTest::Spec
  include Cell::Testing

  it do
    cell("form_for").().gsub(/\s\s/, "").must_equal %{<form class=\"edit_song\" id=\"edit_song_1\" action=\"/songs/1\" accept-charset=\"UTF-8\" method=\"post\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input type=\"hidden\" name=\"_method\" value=\"patch\" /> First <input type=\"text\" value=\"1\" name=\"song[id]\" id=\"song_id\" /><input type=\"text\" name=\"song[artist][id]\" id=\"song_artist_id\" />
</form>}
  end
end