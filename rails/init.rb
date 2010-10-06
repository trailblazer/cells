# encoding: utf-8
require 'cells'

# Tell *Rails* to load files in path:
#
#   * +app/cells+
#
ActiveSupport::Dependencies.autoload_paths << Rails.root.join(*%w[app cells])

# Rails initialization hook.
if defined?(Rails)
  Rails.configuration.after_initialize do
    initializer.loaded_plugins.each do |plugin|
      engine_cells_dir = File.join(plugin.directory, *%w[app cells])

      if plugin.engine? && File.exists?(engine_cells_dir)
        # propagate the view- and code path of this engine-cell:
        ::Cell::Base.view_paths << engine_cells_dir
        ::ActiveSupport::Dependencies.autoload_paths << engine_cells_dir

        # if a path is in +load_once_path+ it won't be reloaded between requests.
        unless config.reload_plugins?
          ::ActiveSupport::Dependencies.load_once_paths << engine_cells_dir
        end
      end
    end
  end
else
  puts "[cells:] NOTE: Rails environment not available. Running isolated."
end