require 'cells/rails/action_controller'
require 'cells/rails/action_view'

module Cells
  module Rails
    autoload :ActionController, 'cells/rails/action_controller'
    autoload :ActionView, 'cells/rails/action_view'
  end
end

# Add extended ActionController behaviour.
ActionController::Base.class_eval do
  include ::Cells::Rails::ActionController
end

# Add extended ActionView behaviour.
ActionView::Base.class_eval do
  include ::Cells::Rails::ActionView
end

# Rails initialization hook.
if defined?(Rails)
  Rails.configuration.after_initialize do
    initializer.loaded_plugins.each do |plugin|
      engine_cells_dir = [File.join(plugin.directory, File.join(*%w[app cells]))]
      next unless plugin.engine?
      next unless File.exists?(engine_cells_dir)

      # propagate the view- and code path of this engine-cell:
      ::Cell::Base.view_paths << engine_cells_dir
      ::ActiveSupport::Dependencies.load_paths << engine_cells_dir

      # if a path is in +load_once_path+ it won't be reloaded between requests.
      unless config.reload_plugins?
        ::ActiveSupport::Dependencies.load_once_paths << engine_cells_dir
      end
    end
  end
else
  puts "[cells:] INFO: Rails environment not available. Running isolated."
end
