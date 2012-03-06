# This file contains VersionStrategies for the Cell and Cells module for Rails >= 3.1.
module Cell
  # Methods to be included in Cell::Rails in 3.1 context.
  module VersionStrategy
    extend ActiveSupport::Concern
    
    include AbstractController::UrlFor  # must be included before _routes is set in Railstie.
    
    
    module ClassMethods
      def view_context_class
        @view_context_class ||= begin
          routes  = _routes  #if respond_to?(:_routes)
          helpers = _helpers #if respond_to?(:_helpers)
          Cell::Rails::View.prepare(routes, helpers)
        end
      end
    end
    
  private    
    def process_opts_for(opts, state)
      opts[:action] = opts[:view] || state
      
      lookup_context.formats = [opts.delete(:format)] if opts[:format]
    end
  end
end


module Cells::Engines
  module VersionStrategy
    def registered_engines
      ::Rails::Application::Railties.engines
    end
    
    def existent_directories_for(path)
      path.existent_directories
    end
  end
end
