require 'sinatra/base'

module Cells
	module Cell
		module Sinatra
      class View
        include ::Sinatra::Templates
        
        def initialize
          @template_cache = Tilt::Cache.new ### FIXME: get @template_cache from sinatra app.
        end
        
        def settings; self.class; end ### FIXME: delegate to sinatra app
        
        #def self.views; []; end
        def self.templates; {}; end### FIXME: delegate to sinatra app
        
        
        def copy_ivars(ivars)
          ivars.each { |ivar, val| instance_variable_set(ivar, val) }
        end
      end
    end
    
    module SinatraMethods
      def assigns ### DISCUSS: move to Cell::Base?
        assigns = {}
        instance_variables.each { |ivar| assigns[ivar] = instance_variable_get(ivar) }
        assigns
      end
      
      
      # Defaultize the passed options from #render.
      def defaultize_render_options_for(options, state)
        options.reverse_merge!  :engine           => :erb,
                                :template_format  => self.class.default_template_format
      end
      
      def render_view_for(options, state)
        # handle :layout, :template_format, :view
        options = defaultize_render_options_for(options, state)
        
        view = ::Cells::Cell::Sinatra::View.new
        view.copy_ivars(assigns)  ### DISCUSS: how can we avoid copying?


        # set instance vars, include helpers:
        views = self.class.view_paths[2]  ### FIXME: use view_paths.first
        file  = find_family_view_for(state, options, views)
        
        ### TODO: compile sinatra options:
        options[:views] = views
        
        # call view.erb(..) or friends:
        view.send(options[:engine], "#{file}.#{options[:template_format]}".to_sym, options)
      end
        
      # Returns the first existing view for +state+ in the inheritance chain.
      def find_family_view_for(state, options, views)
        possible_paths_for_state(state).find do |template_path|
          path = ::File.join(views, "#{template_path}.#{options[:template_format]}.#{options[:engine]}")
          ::File.readable?(path)
        end
      end
        
    end
  end
end