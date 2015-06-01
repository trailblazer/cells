# These methods are automatically added to all controllers and views.
module Cell
  module RailsExtensions
    module ActionController
      def cell(name, model=nil, options={}, &block)
        ::Cell::ViewModel.cell(name, model, options.merge(controller: self), &block)
      end

      def concept(name, model=nil, options={}, &block)
        ::Cell::Concept.cell(name, model, options.merge(controller: self), &block)
      end
    end

    module ActionView
      # Returns the cell instance for +name+. You may pass arbitrary options to your
      # cell.
      #
      #   = cell(:song, :title => "Creeping Out Sara").render(:show)
      def cell(name, *args, &block)
        controller.cell(name, *args, &block)
      end

      # # See Cells::Rails::ActionController#render_cell.
      # def render_cell(name, state, *args, &block)
      #   ::Cell::Rails.render_cell(name, state, controller, *args, &block)
      # end

      def concept(name, *args, &block)
        controller.concept(name, *args, &block)
      end
    end

    # Gets included into Cell::ViewModel in a Rails environment.
    module ViewModel
      extend ActiveSupport::Concern

      def call(*)
        super.html_safe
      end

      def perform_caching?
        ::ActionController::Base.perform_caching
      end

      def cache_store  # we want to use DI to set a cache store in cell/rails.
        ::ActionController::Base.cache_store
      end

      module ClassMethods
        def expand_cache_key(key)
          ::ActiveSupport::Cache.expand_cache_key(key, :cells)
        end
      end
    end
  end
end
