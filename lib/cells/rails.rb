# encoding: utf-8
require 'cells/rails/action_controller'
require 'cells/rails/action_view'

Cell::Base.class_eval do
  helper ::ApplicationHelper if defined?(::ApplicationHelper)
end

# Add extended ActionController behaviour.
ActionController::Base.class_eval do
  include ::Cells::Rails::ActionController
end

# Add extended ActionView behaviour.
ActionView::Base.class_eval do
  include ::Cells::Rails::ActionView
end
