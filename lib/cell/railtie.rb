begin
  require 'rails/railtie'
rescue LoadError
else

  class ApplicationCell < Cell::ViewModel; end
  class ApplicationConcept < Cell::Concept; end

  module Cell
    class Railtie < Rails::Railtie
      require 'cell/rails'
      config.cells = ActiveSupport::OrderedOptions.new
      # FIXME: 1 initializer
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

      rake_tasks do
        load 'tasks/cells.rake'
      end
    end
  end
end
