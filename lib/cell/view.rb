module Cell
  class View < ::ActionView::Base
    
    attr_accessor :cell
    
    
    ### DISCUSS: where/how do WE set template_format (render_view_for_state)?
    # Tries to find the passed template in view_paths. Returns the view on success-
    # otherwise it will throw an ActionView::MissingTemplate exception.
    def try_picking_template_for_path(template_path)
      self.view_paths.find_template(template_path, template_format)
    end    
    
    
    def render(options = {}, local_assigns = {}, &block)
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
