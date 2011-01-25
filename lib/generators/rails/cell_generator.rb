require 'generators/cells/base'

module Rails
  module Generators
    class CellGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_cell_file
        template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      end

      hook_for(:template_engine)
      hook_for(:test_framework)
    end
  end
end
