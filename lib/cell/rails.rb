# These methods are automatically added to all controllers and views.
module Cell
  module RailsExtensions
    module ActionController
      def cell(name, *args, &block)
        ViewModel.cell(name, self, *args, &block)
      end

      def concept(name, *args, &block)
        Concept.cell(name, self, *args, &block)
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
  end
end
