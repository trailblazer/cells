require 'generators/rails/cell_generator'

module Cells
  module Generators
    class CellGenerator < ::Rails::Generators::CellGenerator
      source_root File.expand_path('../../templates', __FILE__)
      
      def say_deprecated
        say "====> This generator is now DEPRECATED. <====", :red
        say "Please use:"
        say "  rails g cell #{class_name} #{actions.join(' ')}"
      end
    end
  end
end
