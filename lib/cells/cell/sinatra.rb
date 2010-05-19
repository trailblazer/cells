require 'sinatra/base'

module Cells
  # Use this in a Sinatra application.
  #
  #   MyApp < Sinatra::Base
  #     helpers Cells::Sinatra
  #     
  #     get "/" do
  #       render_cell(:post, :top10)
  #     end
  module Sinatra
    def render_cell(name, state, opts={})
      ::Cell::Base.render_cell_for(self, name, state, opts)
    end
  end
  
	module Cell
    module SinatraMethods
      # Sinatra::Templates introduces two dependencies:
      #  - it accesses @template_cache
      #  - it uses self.class.templates to reads named templates  ### TODO: implement/test
      #  - invokes methods #settings
      include ::Sinatra::Templates
      alias_method :render_template, :render
      delegate :settings, :to => :controller
      
      def init_framework
        self.class.instance_eval do 
          #attr_accessor :templates
          #templates = {}
          def templates; {}; end
        end
        @template_cache = controller.instance_variable_get(:@template_cache)
      end
      
      
      def render(*args, &block)
        # Argh, we have to find out the receiver for #render. I don't like that.
        options = args.first || {}
        
        if options.kind_of? Hash
          return render_view_for(options, @state_name)
        end
                
        render_template(*args, &block)  # a Sinatra::Templates#render call.
      end
      
      
      # Defaultize the passed options from #render.
      def defaultize_render_options_for(options, state)
        options.reverse_merge!  :engine           => :erb,
                                :template_format  => self.class.default_template_format
      end
      
      def render_view_for(options, state)
        # handle :layout, :template_format, :view
        options = defaultize_render_options_for(options, state)
        
        # set instance vars, include helpers:
        views = self.class.view_paths[2]  ### FIXME: use view_paths.first
        file  = find_family_view_for(state, options, views)
        
        ### TODO: compile sinatra options:
        options[:views] = views
        
        # call erb(..) or friends:
        self.send(options[:engine], "#{file}.#{options[:template_format]}".to_sym, options)
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