# These Methods are automatically added to all Controllers and Views when
# the cells plugin is loaded.
module Cells
  module Rails
    module ActionController
      def cell_for(name, *args, &block)
        return Cell::Rails::ViewModel.cell(name, self, *args, &block) if args.first.is_a?(Hash) and args.first[:collection] # FIXME: we only want this feature in view models for now.
        ::Cell::Base.cell_for(name, self, *args, &block)
      end
      alias_method :cell, :cell_for # DISCUSS: make this configurable?

      def concept_for(name, *args, &block)
        return Cell::Concept.cell(name, self, *args, &block)
      end
      alias_method :concept, :concept_for

      # Renders the cell state and returns the content. You may pass options here, too. They will be
      # around in @opts.
      #
      # Example:
      #
      #   @box = render_cell(:posts, :latest, :user => current_user)
      #
      # If you need the cell instance before it renders, you can pass a block receiving the cell.
      #
      # Example:
      #
      #   @box = render_cell(:comments, :top5) do |cell|
      #     cell.markdown! if config.parse_comments?
      #   end
      def render_cell(name, state, *args, &block)
        ::Cell::Rails.render_cell_for(name, state, self, *args, &block)
      end

      # Expires the cached cell state view, similar to ActionController::expire_fragment.
      # Usually, this method is used in Sweepers.
      # Beside the obvious first two args <tt>cell_name</tt> and <tt>state</tt> you can pass
      # in additional cache key <tt>args</tt> and cache store specific <tt>opts</tt>.
      #
      # Example:
      #
      #  class ListSweeper < ActionController::Caching::Sweeper
      #   observe List, Item
      #
      #   def after_save(record)
      #     expire_cell_state :my_listing, :display_list
      #   end
      #
      # will expire the view for state <tt>:display_list</tt> in the cell <tt>MyListingCell</tt>.
      def expire_cell_state(cell_class, state, args={}, opts=nil)
        key = cell_class.state_cache_key(state, args)
        cell_class.expire_cache_key(key, opts)
      end
    end

    module ActionView
      # Returns the cell instance for +name+. You may pass arbitrary options to your
      # cell.
      #
      #   = cell(:song, :title => "Creeping Out Sara").render(:show)
      def cell_for(name, *args, &block)
        controller.cell_for(name, *args, &block)
      end
      alias_method :cell, :cell_for # DISCUSS: make this configurable?

      # See Cells::Rails::ActionController#render_cell.
      def render_cell(name, state, *args, &block)
        ::Cell::Rails.render_cell_for(name, state, controller, *args, &block)
      end

      def concept(name, *args, &block)
        controller.concept_for(name, *args, &block)
      end
    end
  end
end

# Add extended ActionController behaviour.
ActionController::Base.class_eval do
  include ::Cells::Rails::ActionController
end

# Add extended ActionView behaviour.
ActionView::Base.class_eval do
  include ::Cells::Rails::ActionView
end
