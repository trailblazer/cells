require 'abstract_controller'
require 'action_controller'

module Cell
  class Rails < ActionController::Metal
    include BaseMethods
    include AbstractController
    include Rendering, Layouts, Helpers, Callbacks, Translation
    include ActionController::RequestForgeryProtection
    
    module Rendering
      def render_state(state)
        rack_response = dispatch(state, parent_controller.request)
        
        str = ''      # copied from Response#body.
        rack_response[2].each { |part| str << part.to_s }
        str.html_safe # in fact, i'd love to return a real OutputBuffer here.
      end
    end
    
    class View < ActionView::Base
      def render(options = {}, locals = {}, &block)
        if options[:state] or options[:view]
          return @_controller.render(options, &block)
        end
        
        super
      end
    end
    
    include Rendering
    include Caching
    
    #include AbstractController::Logger
    
    
    #include Cell::ActiveHelper
    cattr_accessor :url_helpers ### TODO: discuss if we really need that or can handle that in cells.rb already.
    
    abstract!
    
    ### DISCUSS: should we pass the parent_controller here?
    def initialize(parent_controller=nil, options={})  ### FIXME: move to BaseMethods.
      @parent_controller  = parent_controller
      @opts = @options    = options
    end
    attr_reader :parent_controller
    
    
    def log(*args); end
    
    
    def self.view_context_class
      controller = self
      
      View.class_eval do
        include controller._helpers
        include Cell::Base.url_helpers if Cell::Rails.url_helpers
      end
      
      
      @view_context_class ||= View
      ### DISCUSS: copy behaviour from abstract_controller/rendering-line 49? (helpers)
    end
    
    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end
    
    def process(*)  # defined in AC::Metal.
      self.response_body = super
    end
    
    delegate :request, :to => :parent_controller
    delegate :config, :to => :parent_controller # DISCUSS: what if a cell has its own config (eg for assets, cells/bassist/images)?
    # DISCUSS: let @controller point to @parent_controller in views, and @cell is the actual real controller?

    
    
    class << self
      def state2view_cache
        @state2view_cache ||= {}
      end
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
      #
      # In Cells we abandoned the term 'partial' in favor of plain 'views' - we don't need to distinguish
      # between both terms. A cell view is both, a view and a kind of partial as it represents only a small
      # part of the page.
      # Just use <tt>:view</tt> and enjoy.
      def render(opts={})
        render_view_for(opts, self.action_name)
      end

      

      # Climbs up the inheritance hierarchy of the Cell, looking for a view for the current +state+ in each level.
      def find_family_view_for_state(state)
        missing_template_exception = nil

        possible_paths_for_state(state).each do |template_path|
          begin
            template = find_template(template_path)
            return template if template
          rescue ::ActionView::MissingTemplate => missing_template_exception
          end
        end
        
        raise missing_template_exception
      end
      
      # Render the view belonging to the given state. Will raise ActionView::MissingTemplate
      # if it can not find one of the requested view template. Note that this behaviour was
      # introduced in cells 2.3 and replaces the former warning message.
      def render_view_for(opts, state)
        return '' if opts[:nothing]

        ### TODO: dispatch dynamically:
        if    opts[:text]   ### FIXME: generic option?
        elsif opts[:inline]
        elsif opts[:file]
        elsif opts[:state]  ### FIXME: generic option
          opts[:text] = render_state(opts[:state])
        else
          # handle :layout, :template_format, :view
          opts = defaultize_render_options_for(opts, state)

          #template    = find_family_view_for_state_with_caching(opts[:view], action_view)
          template    = find_family_view_for_state(opts[:view])
          opts[:template] = template
        end

        opts = sanitize_render_options(opts)
        
        render_to_string(opts)
      end

      # Defaultize the passed options from #render.
      def defaultize_render_options_for(opts, state)
        opts[:template_format]  ||= self.class.default_template_format
        opts[:view]             ||= state
        opts
      end
      
      def sanitize_render_options(opts)
        opts.except!(:view, :state)
      end
		end
end