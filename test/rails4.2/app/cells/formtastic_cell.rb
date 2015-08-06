class FormtasticCell < Cell::ViewModel
  include ActionView::RecordIdentifier
  include Formtastic::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper

  def show
    render
  end
end
