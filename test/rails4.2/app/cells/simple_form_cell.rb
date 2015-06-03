class SimpleFormCell < Cell::ViewModel
  include Cell::Erb
  include ActionView::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  # include ActiveSupport::Configurable
  # include ActionController::RequestForgeryProtection # FIXME: this does NOT activate any protection.

  def protect_against_forgery?
    false
  end

  def show
    render
  end
end