require 'generators/cells/base'

module TestUnit
  module Generators
    class CellGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_test
        @states = actions
        template 'cell_test.rb', File.join('test/cells/', "#{file_name}_cell_test.rb")
      end
    end
  end
end
