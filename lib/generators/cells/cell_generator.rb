require 'generators/cells/base'

module Cells
  module Generators
    class CellGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_cell_file
        template 'cell.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      end

      hook_for(:template_engine)
      hook_for(:test_framework)

      def say_deprecated
        say "====> This generator is now DEPRECATED. <====", :red
        say "Please use:"
        say "  rails g cell #{class_name} #{actions.join(' ')}"
      end
    end
  end
end
