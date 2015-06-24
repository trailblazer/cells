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

      ActiveSupport.on_load(:action_view) do |app|
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
      ViewModel.send(:include, Cell::Slim) if Cell.const_defined?(:Slim, false)
    end
    #   ViewModel.template_engine = app.config.app_generators.rails.fetch(:template_engine, 'erb').to_s

    initializer('cells.development') do |app|
      if Rails.env == "development"
        require "cell/development"
        ViewModel.send(:include, Development)
      end
    end

    rake_tasks do
      load 'tasks/cells.rake'
    end
  end
end
