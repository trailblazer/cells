# This file contains VersionStrategies for the Cell and Cells module for Rails 3.0.
module Cell
  # Methods to be included in Cell::Rails in 3.0 context, where there's no view inheritance.
  module VersionStrategy
    extend ActiveSupport::Concern
    
    class MissingTemplate < ActionView::ActionViewError
      def initialize(message, possible_paths)
        super(message + " and possible paths #{possible_paths}")
      end
    end
    
    
    module ClassMethods
      def view_context_class
        @view_context_class ||= begin
          Class.new(Cell::Rails::View).tap do |klass|
            klass.send(:include, _helpers)
            klass.send(:include, _routes.url_helpers)
          end
        end
      end
      
      # Return the default view path for +state+. Override this if you cell has a differing naming style.
      def view_for_state(state)
        "#{cell_name}/#{state}"
      end

      # Returns all possible view paths for +state+ by invoking #view_for_state on all classes up
      # the inheritance chain.
      def find_class_view_for_state(state)
        return [view_for_state(state)] if superclass.abstract?

        superclass.find_class_view_for_state(state) << view_for_state(state)
      end

      def cell_name
        controller_path
      end
    end
    
  private
    # Computes all possible paths for +state+ by traversing up the inheritance chain.
    def possible_paths_for_state(state)
      self.class.find_class_view_for_state(state).reverse!
    end
    
    # Climbs up the inheritance chain, looking for a view for the current +state+.
    def find_family_view_for_state(state)
      exception       = nil
      possible_paths  = possible_paths_for_state(state)

      possible_paths.each do |template_path|
        begin
          template = find_template(template_path)
          return template if template
        rescue ::ActionView::MissingTemplate => exception
        end
      end

      raise MissingTemplate.new(exception.message, possible_paths)
    end
    
    def process_opts_for(opts, state)
      lookup_context.formats = opts.delete(:format) if opts[:format]
      
      opts[:template] = find_family_view_for_state(opts.delete(:view) || state)
    end
  end
end


module Cells::Engines
  module VersionStrategy
    def registered_engines
      ::Rails::Application.railties.engines
    end
    
    def existent_directories_for(path)
      path.to_a.select { |d| File.directory?(d) }
    end
  end
end
