class FormtasticCell < Cell::ViewModel
  include ActionView::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include Formtastic::Helpers::FormHelper

  def show
    render
  end
end