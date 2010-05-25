module Cell
  class Rails < AbstractBase
    include ::ActionController::Helpers
    include ::ActionController::RequestForgeryProtection
    
      include Cell::ActiveHelper
      
      class_inheritable_array :view_paths, :instance_writer => false
      write_inheritable_attribute(:view_paths, ActionView::PathSet.new) # Force use of a PathSet in this attribute, self.view_paths = ActionView::PathSet.new would still yield in an array
      
      class << self
        attr_accessor :request_forgery_protection_token

        
        
        # Use this if you want Cells to look up view templates
        # in directories other than the default.
        def view_paths=(paths)
          self.view_paths.clear.concat(paths) # don't let 'em overwrite the PathSet.
        end
        
        # A template file will be looked for in each view path. This is typically
        # just RAILS_ROOT/app/cells, but you might want to add e.g.
        # RAILS_ROOT/app/views.
        def add_view_path(path)
          path = ::Rails.root.join(path) if defined?(::Rails)
          self.view_paths << path unless self.view_paths.include?(path)
        end

        

        # Declare a controller method as a helper.  For example,
        #   helper_method :link_to
        #   def link_to(name, options) ... end
        # makes the link_to controller method available in the view.
        def helper_method(*methods)
          methods.flatten.each do |method|
            master_helper_module.module_eval <<-end_eval
              def #{method}(*args, &block)
                @cell.send(:#{method}, *args, &block)
              end
            end_eval
          end
        end

        

        def state2view_cache
          @state2view_cache ||= {}
        end

        def cache_configured?
          ::ActionController::Base.cache_configured?
        end
      end
      
      
      
      
      

      class_inheritable_accessor :allow_forgery_protection
      self.allow_forgery_protection = true

      

      delegate :params, :session, :request, :logger, :to => :controller

      

      # We will soon remove the implicit call to render_view_for, but here it is for your convenience.
      def render_view_for_backward_compat(opts, state)
        ::ActiveSupport::Deprecation.warn "You either didn't call #render or forgot to return a string in the state method '#{state}'. However, returning nil is deprecated for the sake of explicitness"

        render_view_for(opts, state)
      end

      # Renders the view for the current state and returns the markup for the component.
      # Usually called and returned at the end of a state method.
      #
      # ==== Options
      # * <tt>:view</tt> - Specifies the name of the view file to render. Defaults to the current state name.
      # * <tt>:template_format</tt> - Allows using a format different to <tt>:html</tt>.
      # * <tt>:layout</tt> - If set to a valid filename inside your cell's view_paths, the current state view will be rendered inside the layout (as known from controller actions). Layouts should reside in <tt>app/cells/layouts</tt>.
      # * <tt>:locals</tt> - Makes the named parameters available as variables in the view.
      # * <tt>:text</tt> - Just renders plain text.
      # * <tt>:inline</tt> - Renders an inline template as state view. See ActionView::Base#render for details.
      # * <tt>:file</tt> - Specifies the name of the file template to render.
      # * <tt>:nothing</tt> - Will make the component kinda invisible and doesn't invoke the rendering cycle.
      # * <tt>:state</tt> - Instantly invokes another rendering cycle for the passed state and returns.
      # Example:
      #  class MyCell < ::Cell::Base
      #    def my_first_state
      #      # ... do something
      #      render
      #    end
      #
      # will just render the view <tt>my_first_state.html</tt>.
      #
      #    def my_first_state
      #      # ... do something
      #      render :view => :my_first_state, :layout => 'metal'
      #    end
      #
      # will also use the view <tt>my_first_state.html</tt> as template and even put it in the layout
      # <tt>metal</tt> that's located at <tt>$RAILS_ROOT/app/cells/layouts/metal.html.erb</tt>.
      #
      #    def say_your_name
      #      render :locals => {:name => "Nick"}
      #    end
      #
      # will make the variable +name+ available in the view <tt>say_your_name.html</tt>.
      #
      #    def say_your_name
      #      render :nothing => true
      #    end
      #
      # will render an empty string thus keeping your name a secret.
      #
      #
      # ==== Where have all the partials gone?
      # In Cells we abandoned the term 'partial' in favor of plain 'views' - we don't need to distinguish
      # between both terms. A cell view is both, a view and a kind of partial as it represents only a small
      # part of the page.
      # Just use <tt>:view</tt> and enjoy.
      def render(opts={})
        render_view_for(opts, @state_name)  ### FIXME: i don't like the magic access to @state_name here. ugly!
      end

      

      # Climbs up the inheritance hierarchy of the Cell, looking for a view
      # for the current <tt>state</tt> in each level.
      # As soon as a view file is found it is returned as an ActionView::Template
      # instance.
      ### DISCUSS: moved to Cell::View#find_template in rainhead's fork:
      def find_family_view_for_state(state, action_view)
        missing_template_exception = nil

        possible_paths_for_state(state).each do |template_path|
        puts "looking for #{template_path}"
          # we need to catch MissingTemplate, since we want to try for all possible
          # family views.
          begin
            if view = action_view.try_picking_template_for_path(template_path)
              return view
            end
          rescue ::ActionView::MissingTemplate => missing_template_exception
          end
        end

        raise missing_template_exception
      end

      # In production mode, the view for a state/template_format is cached.
      ### DISCUSS: ActionView::Base already caches results for #pick_template, so maybe
      ### we should just cache the family path for a state/format?
      def find_family_view_for_state_with_caching(state, action_view)
        return find_family_view_for_state(state, action_view) unless self.class.cache_configured?

        # in production mode:
        key         = "#{state}/#{action_view.template_format}"
        state2view  = self.class.state2view_cache
        state2view[key] || state2view[key] = find_family_view_for_state(state, action_view)
      end

      

      # Prepares the hash {instance_var => value, ...} that should be available
      # in the ActionView when rendering the state view.
      ### DISCUSS: to we need that at all?
      def assigns_for_view
        assigns = {}
        (self.instance_variables - ivars_to_ignore).each do |k|
         assigns[k[1..-1]] = instance_variable_get(k)
        end
        assigns
      end

      # When passed a copy of the ActionView::Base class, it
      # will mix in all helper classes for this cell in that class.
      def include_helpers_in_class(view_klass)
        view_klass.send(:include, self.class.master_helper_module)
      end

      # Defines the instance variables that should <em>not</em> be copied to the
      # View instance.
      ### DISCUSS: to we need that at all?
      def ivars_to_ignore;  ['@controller']; end
      
      ### TODO: allow log levels.
      def log(message)
        return unless @controller.logger
        @controller.logger.debug(message)
      end
      
    ### TODO: move to module.
        # Render the view belonging to the given state. Will raise ActionView::MissingTemplate
        # if it can not find one of the requested view template. Note that this behaviour was
        # introduced in cells 2.3 and replaces the former warning message.
        def render_view_for(opts, state)
          return '' if opts[:nothing]
  
          action_view = setup_action_view
  
          ### TODO: dispatch dynamically:
          if    opts[:text]   ### FIXME: generic option?
          elsif opts[:inline]
          elsif opts[:file]
          elsif opts[:state]  ### FIXME: generic option
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
          view_class  = Class.new(::Cells::Rails::View)
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