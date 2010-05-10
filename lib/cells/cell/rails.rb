module Cells
	module Cell
		module Rails
		  def self.included(base)
        base.class_eval do
          ###@ include ::ActionController::Helpers
          include ::ActionController::RequestForgeryProtection
          
          class << self
            attr_accessor :request_forgery_protection_token
          end

        end
      end
      ### TODO: move to module.
          # Render the view belonging to the given state. Will raise ActionView::MissingTemplate
          # if it can not find one of the requested view template. Note that this behaviour was
          # introduced in cells 2.3 and replaces the former warning message.
          def render_view_for(opts, state)
            return '' if opts[:nothing]
    
            action_view = setup_action_view
    
            ### TODO: dispatch dynamically:
            if    opts[:text]
            elsif opts[:inline]
            elsif opts[:file]
            elsif opts[:state]
              opts[:text] = render_state(opts[:state])
            else
              # handle :layout, :template_format, :view
              opts = defaultize_render_options_for(opts, state)
    
              # set instance vars, include helpers:
              prepare_action_view_for(action_view, opts)
    
              template    = find_family_view_for_state_with_caching(opts[:view], action_view)
              opts[:file] = template
            end
    
            opts = sanitize_render_options(opts)
    
            action_view.render_for(opts)
          end
    
          # Defaultize the passed options from #render.
          def defaultize_render_options_for(opts, state)
            opts[:template_format]  ||= self.class.default_template_format
            opts[:view]             ||= state
            opts
          end
    
          def prepare_action_view_for(action_view, opts)
            # make helpers available:
            include_helpers_in_class(action_view.class)
            
            import_active_helpers_into(action_view) # in Cells::Cell::ActiveHelper.
    
            action_view.assigns         = assigns_for_view  # make instance vars available.
            action_view.template_format = opts[:template_format]
          end
    
          def setup_action_view
            view_class  = Class.new(::Cells::Cell::View)
            action_view = view_class.new(self.class.view_paths, {}, @controller)
            action_view.cell = self
            action_view
          end
    
          # Prepares <tt>opts</tt> to be passed to ActionView::Base#render by removing
          # unknown parameters.
          def sanitize_render_options(opts)
            opts.except!(:view, :state)
          end
      
		end
	end
end