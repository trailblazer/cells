require 'rails_generator/generators/components/controller/controller_generator'

class CellGenerator < ControllerGenerator
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Cell"

      # Directories
      m.directory File.join('app/cells', class_path)
      m.directory File.join('app/cells', class_path, file_name)
      
      # Cell
      m.template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      
      # View template for each action.
      actions.each do |action|
        path = File.join('app/cells', class_path, file_name, "#{action}.html.erb")
        m.template 'view.html.erb', path,
          :assigns => { :action => action, :path => path }
      end
    end
  end
end
