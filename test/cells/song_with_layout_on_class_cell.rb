require 'cells/song_with_layout_cell'

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
