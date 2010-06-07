# encoding: utf-8

# These Methods are automatically added to all Controllers and Views when
# the cells plugin is loaded.
module Cells
  module Rails
    module ActionController
      # Equivalent to ActionController#render_to_string, except it renders a cell
      # rather than a regular templates.
      def render_cell(name, state, opts={})
        ::Cell::Base.render_cell_for(self, name, state, opts)
      end
      alias_method :render_cell_to_string, :render_cell # just for backward compatibility.

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
      # Call a cell state and return its rendered view.
      #
      # ERB example:
      #   <div id="login">
      #     <%= render_cell :user, :login_prompt, :message => "Please login" %>
      #   </div>
      #
      # If you have a <tt>UserCell</tt> cell in <tt>app/cells/user_cell.rb</tt>, which has a
      # <tt>UserCell#login_prompt</tt> method, this will call that method and then will
      # find the view <tt>app/cells/user/login_prompt.html.erb</tt> and render it. This is
      # called the <tt>:login_prompt</tt> <em>state</em> in Cells terminology.
      #
      # If this view file looks like this:
      #   <h1><%= @opts[:message] %></h1>
      #   <label>name: <input name="user[name]" /></label>
      #   <label>password: <input name="user[password]" /></label>
      #
      # The resulting view in the controller will be roughly equivalent to:
      #   <div id="login">
      #     <h1><%= "Please login" %></h1>
      #     <label>name: <input name="user[name]" /></label>
      #     <label>password: <input name="user[password]" /></label>
      #   </div>
      def render_cell(name, state, opts = {})
        ::Cell::Base.render_cell_for(@controller, name, state, opts)
      end
    end
    
    

    class View < ::ActionView::Base

      attr_accessor :cell
      alias_method :render_for, :render

      ### TODO: this should just be a thin helper.
      ### dear rails folks, could you guys please provide a helper #render and an internal #render_for
      ### so that we can overwrite the helper and cleanly reuse the internal method? using the same
      ### method both internally and externally sucks ass.
      def render(options = {}, local_assigns = {}, &block)
        ### TODO: we have to find out if this is a call to the cells #render method, or to the rails
        ###       method (e.g. when rendering a layout). what a shit.
        if (options.keys & [:view, :state]).present?  ### TODO: is there something like has_keys?
          # that's better: simply delegate render back to the cell/controller.
          return cell.render(options)
        end

        # rails compatibility we should get rid of:
        if partial_path = options[:partial]
          # adds the cell name to the partial name.
          options[:partial] = expand_view_path(partial_path)
        end

        super(options, local_assigns, &block)
      end

      def expand_view_path(path)
        path = "#{cell.cell_name}/#{path}" unless path.include?('/')
        path
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
