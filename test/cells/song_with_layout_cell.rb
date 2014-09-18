class SongWithLayoutCell < Cell::ViewModel
  self.view_paths = ['test/fixtures']

  def show
    render layout: :merry
  end

  def unknown
    render layout: :no_idea_what_u_mean
  end

  def what
    'Xmas'
  end

  def string
    'Right'
  end

  private

  def title
    '<b>Papertiger</b>'
  end
end
