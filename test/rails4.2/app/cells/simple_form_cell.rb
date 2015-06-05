class SimpleFormCell < Cell::ViewModel
  include ActionView::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  # include ActiveSupport::Configurable
  # include ActionController::RequestForgeryProtection # FIXME: this does NOT activate any protection.

  def show
    render
  end
end