require "rails/railtie"

module Cell
  class Railtie < Rails::Railtie
    config.cells = ActiveSupport::OrderedOptions.new

    initializer('cells.attach_router') do |app|
      Cell::ViewModel.class_eval do
        include app.routes.url_helpers # TODO: i hate this, make it better in Rails.
      end
    end

    initializer "cells.template_engine" do |app|
      if defined?(:Haml)
        Cell::ViewModel.template_engine= "haml"
      end
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
      load 'tasks/cells.rake'
    end
  end
end
