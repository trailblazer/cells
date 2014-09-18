class SongCell < Cell::ViewModel
  self.view_paths = ['test/fixtures']

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

  def with_erb
    render template_engine: :erb
  end

  def with_view_name
    @title = "Man Of Steel"
    render :ivar
  end

  private
  def title
    "Papertiger"
  end
end