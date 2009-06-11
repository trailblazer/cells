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
    
    # this prevents cell ivars from being overwritten by same-named
    # controller ivars.
    # we'll hopefully get a cleaner way, or an API, to handle this in rails 3.
    def _copy_ivars_from_controller #:nodoc:
      if @controller
        variables = @controller.instance_variable_names
        variables -= @controller.protected_instance_variables if @controller.respond_to?(:protected_instance_variables)
        variables -= assigns.keys.collect {|key| "@#{key}"} # cell ivars override controller ivars.
        variables.each { |name| instance_variable_set(name, @controller.instance_variable_get(name)) }
      end
    end
  end
end
