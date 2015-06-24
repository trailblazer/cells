class FormForCell < Cell::ViewModel
  include ActionView::RecordIdentifier

  def show
    render
  end
end
