# encoding: utf-8
require 'cells'

# Tell *Rails* to load files in path:
#
#   * +app/cells+
#
dep = ::ActiveSupport::Dependencies

if dep.respond_to?(:autoload_paths)
  dep.autoload_paths << Rails.root.join(*%w[app cells])
else
  dep.load_paths << Rails.root.join(*%w[app cells])
end

# Rails initialization hook.
if defined?(Rails)
  Rails.configuration.after_initialize do
    initializer.loaded_plugins.each do |plugin|
      engine_cells_dir = File.join(plugin.directory, *%w[app cells])

      if plugin.engine? && File.exists?(engine_cells_dir)
        # propagate the view- and code path of this engine-cell:
        ::Cell::Base.view_paths << engine_cells_dir
        if dep.respond_to?(:autoload_paths)
          dep.autoload_paths << engine_cells_dir
        else
          dep.load_paths << engine_cells_dir
        end
        
        # if a path is in +load_once_path+ it won't be reloaded between requests.
        unless config.reload_plugins?
          if dep.respond_to?(:autoload_once_paths)
            dep.autoload_once_paths << engine_cells_dir
          else
            dep.load_once_paths << engine_cells_dir
          end
        end
      end
    end
  end
else
  puts "[cells:] NOTE: Rails environment not available. Running isolated."
end
