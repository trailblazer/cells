require 'generators/trailblazer/view_generator'

module Haml
  module Generators
    class ConceptGenerator < ::Trailblazer::Generators::ViewGenerator

      source_root File.expand_path('../../templates/concept', __FILE__)

    private
      def handler
        :haml
      end
    end
  end
end


