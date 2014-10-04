module Rails
  module Generators
    class ConceptGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)

      class_option :template_engine, :type => :string, desc: 'The template engine'

      check_class_collision suffix: 'Concept'

      argument :actions, type: :array, default: [], banner: 'action action2'

      def create_concept
        template 'concept.rb.erb', File.join('app/concepts', class_path, file_name, 'cell.rb')
      end

      def create_views
        states.each do |state|
          @state = state
          @path = File.join('app/concepts', class_path, file_name, 'views', "#{state}.#{template_engine}")
          template "view.#{template_engine}", @path
        end
      end

      hook_for :test_framework

      private

      def template_engine
        (options[:template_engine] || Rails.application.config.app_generators.rails[:template_engine] || 'erb').to_s
      end

      def states
        (['show'] + actions).uniq
      end
    end
  end
end
