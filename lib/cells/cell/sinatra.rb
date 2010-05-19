require 'sinatra/base'

module Cells
	module Cell
		module Sinatra
      class View
        include ::Sinatra::Templates
        
        # Sinatra::Templates introduces two dependencies:
        #  - it accesses @template_cache
        #  - it uses self.class.templates to reads named templates
        #  - invokes methods #settings
        
        class << self
          attr_accessor :templates
        end
        
        attr_reader :app
        
        
        def initialize(app=nil)
          @app = app
        end
        
        delegate :settings, :to => :app
        
        
        def method_missing(name, *args)
          app.send(name, *args)
        end
        

        
        
        def prepare_for_cell!(cell)
          ivars = cell.assigns  ### DISCUSS: pass as separate arguments?
          
          ivars.each { |ivar, val| instance_variable_set(ivar, val) } ### DISCUSS: how can we avoid copying?
          
          
          
          
          @template_cache = app.instance_variable_get(:@template_cache)
          
          self.class.templates = {} ### TODO: get class_inheritable_hash from cell!
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
        
        view = ::Cells::Cell::Sinatra::View.new(self.controller)
        #view.copy_ivars(assigns)  
        view.prepare_for_cell!(self)


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