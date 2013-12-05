require 'rails/generators'
require 'rails/generators/named_base'

module Cells
  module Generators
    class Base < ::Rails::Generators::NamedBase
      class_option :template_engine
      class_option :test_framework
      class_option :base_cell_class, :type => :string, :default => "Cell::Rails"
      class_option :base_cell_path

      argument :actions, :type => :array, :default => [], :banner => "action action"
      check_class_collision :suffix => "Cell"

    private
      def base_path
        path = (options[:base_cell_path] || 'app/cells').to_s
        File.join(path, class_path, file_name)
      end
    end
  end
end
