require 'rails/generators'
require 'rails/generators/named_base'

module Trailblazer
  module Generators
    class Cell < ::Rails::Generators::NamedBase
      class_option :template_engine
      class_option :test_framework
      class_option :base_cell_class, :type => :string, :default => "Cell::Rails"
      class_option :base_cell_path

      argument :actions, :type => :array, :default => [:show], :banner => "action action"

    private
      def base_path
        path = (options[:base_cell_path] || 'app/concepts').to_s
        File.join(path, class_path, file_name)
      end
    end
  end
end
