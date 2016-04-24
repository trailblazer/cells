require 'rails/railtie'

module Cell
  class Railtie < Rails::Railtie
    require 'cell/rails'
    config.cells = ActiveSupport::OrderedOptions.new

    initializer('cells.attach_router') do |app|
      ViewModel.class_eval do
        include app.routes.url_helpers # TODO: i hate this, make it better in Rails.
      end
    end

    # ruthlessly stolen from the zurb-foundation gem.
    initializer 'cells.update_asset_paths' do |app|
      Array(app.config.cells.with_assets).each do |cell_class|
        # puts "@@@@@ #{cell_class.camelize.constantize.prefixes}"
        app.config.assets.paths += cell_class.camelize.constantize.prefixes # Song::Cell.prefixes
      end
    end

    initializer "cells.rails_extensions" do |app|
      ActiveSupport.on_load(:action_controller) do
        self.class_eval do
          include ::Cell::RailsExtensions::ActionController
        end
      end

      ActiveSupport.on_load(:action_view) do
        self.class_eval do
          include ::Cell::RailsExtensions::ActionView
        end
      end
    end

    initializer "cells.include_default_helpers" do
      # include asset helpers (image_path, font_path, ect)
      ViewModel.class_eval do
        include ActionView::Helpers::FormHelper # includes ActionView::Helpers::UrlHelper, ActionView::Helpers::FormTagHelper
        include ::Cell::RailsExtensions::HelpersAreShit

        include ActionView::Helpers::AssetTagHelper
      end

      # set VM#cache_store, etc.
      ViewModel.send(:include, RailsExtensions::ViewModel)
    end

    # TODO: allow to turn off this.
    initializer "cells.include_template_module", after: "cells.include_default_helpers" do
      # yepp, this is happening. saves me a lot of coding in each extension.
      ViewModel.send(:include, Cell::Erb) if Cell.const_defined?(:Erb, false)
      ViewModel.send(:include, Cell::Haml) if Cell.const_defined?(:Haml, false)
      ViewModel.send(:include, Cell::Hamlit) if Cell.const_defined?(:Hamlit, false)
      ViewModel.send(:include, Cell::Slim) if Cell.const_defined?(:Slim, false)
    end
    #   ViewModel.template_engine = app.config.app_generators.rails.fetch(:template_engine, 'erb').to_s

    initializer('cells.reloading') do |app|
      unless app.config.cache_classes
        require "cell/development"
        ViewModel.send(:include, Development::Clearable)

        callback = lambda do
          Cell::ViewModel.clear_templates!
        end

        if app.config.reload_classes_only_on_change
          dirs = {}
          extentions = ["haml", "erb", "slim"]
          view_paths = Cell::ViewModel.view_paths + Cell::Concept.view_paths
          view_paths.each do |path|
            dirs[path] = extentions
          end

          reloader = app.config.file_watcher.new([], dirs, &callback)
          app.reloaders << reloader

          ActionDispatch::Reloader.to_prepare(prepend: true) do
            reloader.execute_if_updated
          end
        else
          ActionDispatch::Reloader.to_cleanup(&callback)
        end
      end
    end

    rake_tasks do
      load 'tasks/cells.rake'
    end
  end
end
