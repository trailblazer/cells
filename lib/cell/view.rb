module Cell
  class View < ActionView::Base
    
    def try_picking_template_for_path(template_path)
      puts "checking #{template_path}"
        
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
    
  end
end
