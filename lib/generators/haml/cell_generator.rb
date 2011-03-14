require 'generators/cells/view_generator'

module Haml
  module Generators
    class CellGenerator < ::Cells::Generators::ViewGenerator
      
      source_root File.expand_path('../../templates', __FILE__)
      
    private
      def handler
        :haml
      end
    end
  end
end


