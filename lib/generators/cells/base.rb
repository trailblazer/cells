require 'rails/generators'
require 'rails/generators/named_base'

module Cells
  module Generators
    class Base < ::Rails::Generators::NamedBase
      class_option :template_engine
      class_option :test_framework
      class_option :base_cell_class, :type => :string, :default => "Cell::Rails"

      argument :actions, :type => :array, :default => [], :banner => "action action"
      check_class_collision :suffix => "Cell"
      
    private
      def base_path
        File.join('app/cells', class_path, file_name)
      end
    end
  end
end
