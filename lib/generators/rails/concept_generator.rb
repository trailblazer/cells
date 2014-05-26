require 'generators/trailblazer/base'

module Rails
  module Generators
    class ConceptGenerator < ::Trailblazer::Generators::Cell
      source_root File.expand_path('../../templates/concept', __FILE__)

      def create_cell_file
        template 'cell.rb', "#{base_path}/cell.rb"
      end

      hook_for(:template_engine)
      hook_for(:test_framework)
    end
  end
end
