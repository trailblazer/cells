#require 'rails_generator/generators/components/controller/controller_generator'
require 'rails/generators/named_base'

module Cells
module Generators
class CellGenerator < ::Rails::Generators::NamedBase
  argument :actions, :type => :array, :default => [], :banner => "action action"
  check_class_collision :suffix => "Cell"
  
  source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  
  class_option :template_engine, :type => :string, :aliases => "-t", :desc => "Template engine for the views. Available options are 'erb' and 'haml'."
  
  def create_cell_file
    template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
  end
  
  def create_views
    for state in actions do
      @state  = state
      @path   = File.join('app/cells', file_name, "#{state}.html.erb")
      
      template 'view.erb', @path
    end
  end
      # Functional test for the widget.
      #m.template 'cell_test.rb', File.join('test/cells/', "#{file_name}_cell_test.rb"), :assigns => {:states => actions}
    #end
  #end

  #def add_options!(opt)
  #  opt.separator ''
  #  opt.separator 'Options:'#

    # Allow option to generate HAML views instead of ERB.
    #opt.on('--haml',
    #"Generate HAML output instead of the default ERB.") do |v|
    #  options[:haml] = v
    #end
  #end

  #def banner
  #  "Usage: #{$0} cell NAME a_view another_view ... [--haml]"
  #end

end

end;end