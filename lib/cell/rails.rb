require 'abstract_controller'
require 'cell'

module Cell
  class Rails < AbstractController::Base
    include Cell
    include AbstractController
    include Rendering, Layouts, Helpers, Callbacks, Translation, Logger
    include ActionController::RequestForgeryProtection


    class View < ActionView::Base
      def render(*args, &block)
        options = args.first.is_a?(::Hash) ? args.first : {}  # this is copied from #render by intention.
        
        return controller.render(*args, &block) if options[:state] or options[:view]
        super
      end
    end


    class MissingTemplate < ActionView::ActionViewError
      def initialize(message, possible_paths)
        super(message + " and possible paths #{possible_paths}")
      end
    end


    module Rendering
      # Invoke the state method for +state+ which usually renders something nice.
      def render_state(state, *args)
        process(state, *args)
      end
    end


    module Metal
      delegate :session, :params, :request, :config, :to => :parent_controller
    end 
    
    
    include Metal
    include Rendering
    include Caching
    
    attr_reader :parent_controller
    attr_accessor :options
    
    abstract!


    def initialize(parent_controller, *args)
      @parent_controller  = parent_controller
      setup_backwardibility(*args)
    end
    
    # Some people still like #options and assume it's a hash.
    def setup_backwardibility(*args)
      @options = (args.first.is_a?(Hash) and args.size == 1) ? args.first : args
      @opts    = ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new(self, :options)
    end
    
    def self.view_context_class
      controller = self

      View.class_eval do
        include controller._helpers
        include controller._routes.url_helpers
      end


      @view_context_class ||= View
    end

    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end

    # Renders the view for the current state and returns the markup.
    # Don't forget to return the markup itself from the state method.
    #
    # === Options
    # +:view+::   Specifies the name of the view file to render. Defaults to the current state name.
    # +:layout+:: Renders the state wrapped in the layout. Layouts reside in <tt>app/cells/layouts</tt>.
    # +:locals+:: Makes the named parameters available as variables in the view.
    # +:text+::   Just renders plain text.
    # +:inline+:: Renders an inline template as state view. See ActionView::Base#render for details.
    # +:file+::   Specifies the name of the file template to render.
    # +:nothing+:: Doesn't invoke the rendering process.
    # +:state+::  Instantly invokes another rendering cycle for the passed state and returns. You may pass arbitrary state-args to the called state.  
    #
    # Example:
    #  class MusicianCell < ::Cell::Base
    #    def sing
    #      # ... laalaa
    #      render
    #    end
    #
    # renders the view <tt>musician/sing.html</tt>.
    #
    #    def sing
    #      # ... laalaa
    #      render :view => :shout, :layout => 'metal'
    #    end
    #
    # renders <tt>musician/shout.html</tt> and wrap it in <tt>app/cells/layouts/metal.html.erb</tt>.
    #
    # === #render is explicit!
    # You can also alter the markup from #render. Just remember to return it.
    #
    #   def sing
    #     render + render + render
    #   end
    #
    # will render three concated views.
    #
    # === Partials?
    #
    # In Cells we abandoned the term 'partial' in favor of plain 'views' - we don't need to distinguish
    # between both terms. A cell view is both, a view and a kind of partial as it represents only a fragment
    # of the page.
    #
    # Just use <tt>:view</tt> and enjoy.
    #
    # === Using states instead of helpers
    #
    # Sometimes it's useful to not only render a view but also invoke the associated state. This is 
    # especially helpful when replacing helpers. Do that with <tt>render :state</tt>.
    #
    #   def show_cheap_item(item)
    #     render if item.price <= 1
    #   end
    #
    # A view could use this state in place of an odd helper.
    #
    #   - @items.each do |item|
    #     = render({:state => :show_cheap_item}, item)
    #
    # This calls the state method which in turn will render its view - if the item isn't too expensive.
    def render(*args)
      render_view_for(self.action_name, *args)
    end

  private
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
    
    # Renders the view belonging to the given state. Will raise ActionView::MissingTemplate
    # if it can't find a view.
    def render_view_for(state, *args)
      opts = args.first.is_a?(::Hash) ? args.shift : {}
      
      return "" if opts[:nothing]
      
      if opts[:state]
        opts[:text] = render_state(opts.delete(:state), *args)
      elsif (opts.keys & [:text, :inline, :file]).blank?
        opts = defaultize_render_options_for(opts, state)
        opts[:template] = find_family_view_for_state(opts.delete(:view))
      end
      
      render_to_string(opts).html_safe # ActionView::Template::Text doesn't do that for us.
    end
    
    def defaultize_render_options_for(opts, state)
      opts.reverse_merge!(:view => state)
    end
  end
end
