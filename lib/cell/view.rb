module Cell
  class View < ActionView::Base
    
    attr_accessor :cell
    
    
    def try_picking_template_for_path(template_path)
      #puts "checking #{template_path}"
      # partly stolen from ActionView::Base#_pick_template.
        
      path = template_path.sub(/^\//, '')
      if m = path.match(/(.*)\.(\w+)$/)
        template_file_name, template_file_extension = m[1], m[2]
      else
        template_file_name = path
      end

      if template = self.view_paths["#{template_file_name}.#{template_format}"]
        return template
      end
      
      nil
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
