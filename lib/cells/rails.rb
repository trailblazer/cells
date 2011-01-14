# These Methods are automatically added to all Controllers and Views when
# the cells plugin is loaded.
module Cells
  module Rails
    module ActionController
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
      def render_cell(name, state, opts={}, &block)
        ::Cell::Base.render_cell_for(self, name, state, opts, &block)
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
      def expire_cell_state(cell_name, state, args={}, opts=nil)
        key = ::Cell::Base.cache_key_for(cell_name, state, args)
        ::Cell::Base.expire_cache_key(key, opts)
      end
    end


    module ActionView
      # See Cells::Rails::ActionController#render_cell.
      def render_cell(name, state, opts = {}, &block)
        # This is so that we have this "outer" view object available to us from within the cell (available via @opts[:outer_view] or the outer_view helper) and can use Cells' outer_content_for, etc.
        opts.merge! :outer_view => self
        ::Cell::Base.render_cell_for(controller, name, state, opts, &block)
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
