class FormtasticCell < Cell::ViewModel
  include ActionView::RecordIdentifier
  include Formtastic::Helpers::FormHelper

  def show
    render
  end
end
