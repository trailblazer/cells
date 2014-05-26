require 'generators/trailblazer/view_generator'

module Erb
  module Generators
    class ConceptGenerator < ::Trailblazer::Generators::ViewGenerator

      source_root File.expand_path('../../templates/concept', __FILE__)

    private
      def handler
        :erb
      end
    end
  end
end


