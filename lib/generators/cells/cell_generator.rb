require 'rails/generators'
require 'rails/generators/named_base'

module Cells
  module Generators
    class CellGenerator < ::Rails::Generators::NamedBase
      argument :actions, :type => :array, :default => [], :banner => "action action"
      check_class_collision :suffix => "Cell"

      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      class_option :view_engine, :type => :string, :aliases => "-t", :desc => "Template engine for the views. Available options are 'erb' and 'haml'.", :default => "erb"
      class_option :haml, :type => :boolean, :default => false


      def create_cell_file
        template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      end

      def create_views
        if options[:view_engine].to_s == "haml" or options[:haml]
          create_views_for(:haml)
        else
          create_views_for(:erb)
        end
      end

      def create_test
        @states = actions
        template 'cell_test.rb', File.join('test/cells/', "#{file_name}_cell_test.rb")
      end

    protected

      def create_views_for(engine)
        for state in actions do
          @state  = state
          @path   = File.join('app/cells', file_name, "#{state}.html.#{engine}")

          template "view.#{engine}", @path
        end
      end
    end
  end
end
