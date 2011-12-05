module Cell
  module Rendering
    extend ActiveSupport::Concern
    
    # Invoke the state method for +state+ which usually renders something nice.
    def render_state(state, *args)
      process(state, *args)
    end
    
    # Renders the view for the current state and returns the markup.
    # Don't forget to return the markup itself from the state method.
    #
    # === Options
    # +:view+::   Specifies the name of the view file to render. Defaults to the current state name.
    # +:layout+:: Renders the state wrapped in the layout. Layouts reside in <tt>app/cells/layouts</tt>.
    # +:locals+:: Makes the named parameters available as variables in the view.
    # +:text+::   Just renders plain text.
    # +:inline+:: Renders an inline template as state view. See ActionView::Base#render for details.
    # +:file+::   Specifies the name of the file template to render.
    # +:nothing+:: Doesn't invoke the rendering process.
    # +:state+::  Instantly invokes another rendering cycle for the passed state and returns. You may pass arbitrary state-args to the called state.  
    # +:format+:: Sets a different template format, e.g. +:json+. Use this option with caution as it currently modifies the global format variable. This might lead to unexpected subsequent render behaviour due to a design flaw in Rails.
    #
    # Example:
    #  class MusicianCell < ::Cell::Base
    #    def sing
    #      # ... laalaa
    #      render
    #    end
    #
    # renders the view <tt>musician/sing.html</tt>.
    #
    #    def sing
    #      # ... laalaa
    #      render :view => :shout, :layout => 'metal'
    #    end
    #
    # renders <tt>musician/shout.html</tt> and wrap it in <tt>app/cells/layouts/metal.html.erb</tt>.
    #
    # === #render is explicit!
    # You can also alter the markup from #render. Just remember to return it.
    #
    #   def sing
    #     render + render + render
    #   end
    #
    # will render three concated views.
    #
    # === Partials?
    #
    # In Cells we abandoned the term 'partial' in favor of plain 'views' - we don't need to distinguish
    # between both terms. A cell view is both, a view and a kind of partial as it represents only a fragment
    # of the page.
    #
    # Just use <tt>:view</tt> and enjoy.
    #
    # === Using states instead of helpers
    #
    # Sometimes it's useful to not only render a view but also invoke the associated state. This is 
    # especially helpful when replacing helpers. Do that with <tt>render :state</tt>.
    #
    #   def show_cheap_item(item)
    #     render if item.price <= 1
    #   end
    #
    # A view could use this state in place of an odd helper.
    #
    #   - @items.each do |item|
    #     = render({:state => :show_cheap_item}, item)
    #
    # This calls the state method which in turn will render its view - if the item isn't too expensive.
    def render(*args)
      render_view_for(self.action_name, *args)
    end
  
  private
    # Renders the view belonging to the given state. Will raise ActionView::MissingTemplate
    # if it can't find a view.
    def render_view_for(state, *args)
      opts = args.first.is_a?(::Hash) ? args.shift : {}
      
      return "" if opts[:nothing]
      
      if opts[:state]
        opts[:text] = render_state(opts.delete(:state), *args)
      elsif (opts.keys & [:text, :inline, :file]).blank?
        process_opts_for(opts, state)
      end
      
      render_to_string(opts).html_safe # ActionView::Template::Text doesn't do that for us.
    end
    
    
    module ClassMethods
      # Main entry point for #render_cell.
      def render_cell_for(name, state, *args)
        cell = create_cell_for(name, *args)
        yield cell if block_given?
        
        render_cell_state(cell, state, *args)
      end
    
    private
      def render_cell_state(cell, state, *args)
        cell.render_state(state, *args)
      end
    end
  end
end
