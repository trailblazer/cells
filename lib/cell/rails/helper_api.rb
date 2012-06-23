module Cell
  # Allows using many Rails gem in your cells outside of a Rails environment.
  class Rails
    module HelperAPI
      module InternalHelpers
        def protect_against_forgery? # used in form_tag_helper.rb:651
          false
        end
        
        def _routes # FIXME: where is this set in rails?
          self.class._routes
        end
      end
      
      extend ActiveSupport::Concern
      
      module ClassMethods
        attr_accessor :_routes
        
        def helper_modules
          [_helpers, InternalHelpers]
        end
        
        def view_context_class
          super
          @view_context_class._routes = _routes
          @view_context_class
        end
        
        def action_methods
          # DISCUSS: we have to overwrite this to avoid a stupid dependency in AbstractController::UrlFor where _routes.named_routes.helper_names is accessed.
          public_instance_methods(true).map { |x| x.to_s }
        end
      end
    end
  end
end
