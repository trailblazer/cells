class SimpleFormCell < Cell::ViewModel
  include ActionView::RecordIdentifier
  include SimpleForm::ActionViewExtensions::FormHelper

  # include ActiveSupport::Configurable
  # include ActionController::RequestForgeryProtection # FIXME: this does NOT activate any protection.

  def show
    render
  end
end
