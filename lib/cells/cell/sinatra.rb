require 'sinatra/base'

module Cells
	module Cell
		module Sinatra
      class View
        include ::Sinatra::Templates
        
        def initialize
          @template_cache = Tilt::Cache.new
        end
        
        def settings; self.class; end
        
        #def self.views; []; end
        def self.templates; {}; end
      end


    end
    
    module SinatraMethods
      def sinatra; end
      
      # Defaultize the passed options from #render.
          def defaultize_render_options_for(opts, state)
            opts[:template_format]  ||= self.class.default_template_format
            #opts[:view]             ||= state
            opts.reverse_merge! :engine       => :erb
            opts
          end
      
      def render_view_for(options, state)
          # handle :layout, :template_format, :view
          options = defaultize_render_options_for(options, state)


          # set instance vars, include helpers:
          
          views = self.class.view_paths[2]  ### FIXME: use view_paths.first

          file = find_family_view_for(state, options, views)
          
          
          c = ::Cells::Cell::Sinatra::View.new
          #c.instance_variable_set :@items, []
          
          
          puts "template: #{file.inspect}"
          
          c.erb "#{file}.#{options[:template_format]}".to_sym, :views => views
        end
        
        
        def find_family_view_for(state, options, views)
          possible_paths_for_state(state).each do |template_path|
            path = ::File.join(views, "#{template_path}.#{options[:template_format]}.#{options[:engine]}")
            
            return template_path if File.readable?(path)
          end
        end
        
    end
  end
end