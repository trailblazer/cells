require "rails/railtie"

module Cells
  class Railtie < ::Rails::Railtie
    config.cells = ActiveSupport::OrderedOptions.new


    initializer "cells.attach_router" do |app|
      Cell::Base.class_eval do
        include app.routes.url_helpers # TODO: i hate this, make it better in Rails.
      end
    end

    initializer "cells.setup_engines_view_paths" do |app|
      Cells::Engines.append_engines_view_paths_for(app.config.action_controller)
    end

    # ruthlessly stolen from the zurb-foundation gem.
    add_paths_block = lambda do |app|
      (app.config.cells.with_assets or []).each do |name|
        # FIXME: this doesn't take engine cells into account.
        app.config.assets.paths << "#{app.root}/app/cells/#{name}/assets"
        app.config.assets.paths << "#{app.root}/app/concepts/#{name}/assets" # TODO: find out type.
      end
    end

    # Standard initializer
    initializer 'cells.update_asset_paths', &add_paths_block

    # run at assets:precompile even when `config.assets.initialize_on_precompile = false`
    initializer 'cells.update_asset_paths', :group => :assets, &add_paths_block


    rake_tasks do
      load "cells/cells.rake"
    end
  end
end
