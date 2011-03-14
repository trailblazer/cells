require 'generators/cells/view_generator'

module Slim
  module Generators
    class CellGenerator < ::Cells::Generators::ViewGenerator
      
      source_root File.expand_path('../../templates', __FILE__)
    
    private
      def handler
        :slim
      end
    end
  end
end


