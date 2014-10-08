begin
  require 'rails/railtie'
rescue LoadError
else
  module Cell
    class Railtie < Rails::Railtie
      require 'cell/rails'
      config.cells = ActiveSupport::OrderedOptions.new

      initializer('cells.attach_router') do |app|
        ViewModel.class_eval do
          include app.routes.url_helpers # TODO: i hate this, make it better in Rails.
        end
      end

      initializer 'cells.template_engine' do |app|
        ViewModel.template_engine = app.config.app_generators.rails.fetch(:template_engine, 'erb').to_s
      end

      # ruthlessly stolen from the zurb-foundation gem.
      initializer 'cells.update_asset_paths' do |app|
        Array(app.config.cells.with_assets).each do |name|
          # FIXME: this doesn't take engine cells into account.
          app.config.assets.paths.append "#{app.root}/app/cells/#{name}/assets"
          app.config.assets.paths.append "#{app.root}/app/concepts/#{name}/assets" # TODO: find out type.
        end
      end

      initializer('cells.rails_extensions') do |app|
        ActiveSupport.on_load(:action_controller) do
          self.class_eval do
            include ::Cell::RailsExtensions::ActionController
          end
        end

        ActiveSupport.on_load(:action_view) do
          self.class_eval do
            include ::Cell::RailsExtensions::ActionView
          end

          #include assert helpers (image_path, font_path, ect)
          ViewModel.class_eval do
            include ActionView::Helpers::AssetTagHelper
          end
        end
      end

      rake_tasks do
        load 'tasks/cells.rake'
      end
    end
  end
end
