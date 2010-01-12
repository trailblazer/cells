require 'rails_generator/generators/components/controller/controller_generator'

class CellGenerator < ControllerGenerator

  attr_reader :template_type

  def initialize(runtime_args, runtime_options = {})
    super
    @template_type = options[:haml] ? :haml : :erb
  end

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
        path = File.join('app/cells', class_path, file_name, "#{action}.html.#{template_type}")
        m.template "view.html.#{template_type}", path,
          :assigns => { :action => action, :path => path }
      end
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'

    # Allow option to generate HAML views instead of ERB.
    opt.on('--haml',
    "Generate HAML output instead of the default ERB.") do |v|
      options[:haml] = v
    end
  end

  def banner
    "Usage: #{$0} cell NAME a_view another_view ... [--haml]"
  end

end
