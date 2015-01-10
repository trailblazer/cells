# FIXME: remove AC dependency by delegating forgery
require 'action_controller'

# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class

# TODO: warn when using ::property but not passing in model in constructor.
module Cell
  class ViewModel < AbstractController::Base
    abstract!

    extend Uber::InheritableAttr
    extend Uber::Delegates

    inheritable_attr :view_paths
    self.view_paths = ["app/cells"] # DISCUSS: provide same API as rails?

    inheritable_attr :template_engine
    self.template_engine = "erb"

    class << self
      def templates
        @templates ||= Templates.new # note: this is shared in subclasses. do we really want this?
      end
    end


    include Prefixes
    extend SelfContained

    include Uber::Builder


    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore
    end

    include ActionController::RequestForgeryProtection
    delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller

    attr_reader :model


    module Helpers
      # Renders collection of cells.
      def cells_collection(name, controller, array, options)
        method = options.delete(:method) || :show
        join = options.delete(:collection_join)
        array.collect { |model| cell_for(name, *[controller, model, options]).call(method) }.join(join).html_safe
      end

      # Returns cell instance.
      def cell(name, controller, model=nil, options={}, &block) # classic Rails fuzzy API.
        if model.is_a?(Hash) and array = model.delete(:collection)
          return cells_collection(name, controller, array, model)
        end

        cell_for(name, controller, model, options, &block)
      end
    end
    extend Helpers


    class << self
      def property(*names)
        delegates :model, *names # Uber::Delegates.
      end

      include Helpers


      def cell_for(name, controller, *args)
        class_from_cell_name(name).build_cell(controller, *args)
      end

      def class_from_cell_name(name)
        "#{name}_cell".classify.constantize
      end

      def build_cell(controller, *args)
        class_builder.call(*args).new(controller, *args) # Uber::Builder::class_builder.
      end
    end

    def cell(name, *args)
      self.class.cell(name, parent_controller, *args)
    end


    def initialize(controller, model=nil, options={})
      @parent_controller = controller # TODO: this is removed in 4.0.

      setup!(model, options)
    end
    attr_reader :parent_controller
    alias_method :controller, :parent_controller


    # render :show
    def render(options={})
      options = normalize_options(options, caller) # TODO: call render methods with call(:show), call(:comments) instead of directly #comments?
      render_to_string(options)
    end

    def render_to_string(options)
      template = template_for(options[:view], options[:template_engine]) # TODO: cache template with path/lookup keys.
      content  = template.render(self, options[:locals])

      # TODO: allow other (global) layout dirs.
      with_layout(options[:layout], content)
    end


    # Invokes the passed method (defaults to :show). This will respect caching and marks the string as html_safe.
    #
    # Please use #call instead of calling methods directly. This allows adding caching later without changing
    # your code.
    #
    # Yields +self+ (the cell instance) to an optional block.
    def call(state=:show, *args)
      content = render_state(state, *args)
      yield self if block_given?

      content.to_s.html_safe
    end

    alias_method :to_s, :call

  private
    attr_reader :options

    def setup!(model, options)
      @model   = model
      @options = options
      # or: create_twin(model, options)
    end

    module Rendering
      def render_state(*args)
        send(*args)
      end
    end
    include Rendering
    include Caching

    def output_buffer
      @output_buffer ||= []
    end
    attr_writer :output_buffer # TODO: test that, this breaks in MM.

    def template_for(view, engine)
      base = self.class.view_paths
      # we could also pass _prefixes when creating class.templates, because prefixes are never gonna change per instance. not too sure if i'm just assuming this or if people need that.
      self.class.templates[base, _prefixes, view, engine] or raise TemplateMissingError.new(base, _prefixes, view, engine, nil)
    end

    def with_layout(layout, content)
      return content unless layout

      template = template_for(layout, self.class.template_engine) # we could also allow a different layout engine.
      template.render(self) { content }
    end

    def normalize_options(options, caller)
      options = if options.is_a?(Hash)
        options.reverse_merge(:view => state_for_implicit_render(caller)) # TODO: test implicit render!
      else
        {:view => options.to_s}
      end

      options[:template_engine] ||= self.class.template_engine # DISCUSS: in separate method?

      process_options!(options)
      options
    end

    # Overwrite #process_options in included feature modules, but don't forget to call +super+.
    module ProcessOptions
      def process_options!(options)
      end
    end
    include ProcessOptions


    def state_for_implicit_render(caller)
      caller[0].match(/`(\w+)/)[1]
    end

    include Layout


    if defined?(ActionView)
      # FIXME: this module is to fix a design flaw in Rails 4.0. the problem is that AV::UrlHelper mixes in the wrong #url_for.
      # if we could mix in everything else from the helper except for the #url_for, it would be fine.
      # FIXME: fix that in rails core.
      if Cell.rails_version <= Gem::Version.new('4.0')
        include ActionView::Helpers::UrlHelper # gives us breaking #url_for.

        def url_for(options = nil) # from ActionDispatch:R:UrlFor.
          case options
            when nil
              _routes.url_for(url_options.symbolize_keys)
            when Hash
              _routes.url_for(options.symbolize_keys.reverse_merge!(url_options))
            when String
              options
            when Array
              polymorphic_url(options, options.extract_options!)
            else
              polymorphic_url(options)
          end
        end

        public :url_for
      else
        include ActionView::Helpers::UrlHelper
      end
      include ActionView::Helpers::FormTagHelper
    end
  end
end
