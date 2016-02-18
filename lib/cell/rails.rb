# These methods are automatically added to all controllers and views.
module Cell
  module RailsExtensions
    module ActionController
      def cell(name, model=nil, options={})
        ::Cell::ViewModel.cell(name, model, options.merge(controller: self)).tap do |cell|
          if block_given?
            if cell.is_a?(::Cell::CellCollection)
              cell.cells.each { |c| yield c }
            else
              yield cell
            end
          end
        end
      end

      def concept(name, model=nil, options={})
        ::Cell::Concept.cell(name, model, options.merge(controller: self)) do |concept|
          if block_given?
            if concept.is_a?(::Cell::CellCollection)
              concept.cells.each { |c| yield c }
            else
              yield concept
            end
          end
        end
      end
    end

    module ActionView
      # Returns the cell instance for +name+. You may pass arbitrary options to your
      # cell.
      #
      #   = cell(:song, title: "Creeping Out Sara").(:show)
      def cell(name, *args, &block)
        controller.cell(name, *args, &block)
      end

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

    module CellCollection
      extend ActiveSupport::Concern

      def call(*)
        super.html_safe
      end
    end
  end
end
