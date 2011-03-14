require 'generators/cells/view_generator'

module Erb
  module Generators
    class CellGenerator < ::Cells::Generators::ViewGenerator
      
      source_root File.expand_path('../../templates', __FILE__)
      
    private
      def handler
        :erb
      end
    end
  end
end
