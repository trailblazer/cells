# FIXME: remove AC dependency by delegating forgery
require 'action_controller'

# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class

# TODO: warn when using ::property but not passing in model in constructor.
module Cell
  class ViewModel
    include Abstract
    abstract!

    def controller_path
      self.class.controller_path
    end

    extend Uber::InheritableAttr
    extend Uber::Delegates

    inheritable_attr :view_paths
    self.view_paths = ["app/cells"]

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

    # FIXME: this is all rails-only.
    # DISCUSS: who actually uses forgery protection with cells? it is not working since 4, anyway?
    # include ActionController::RequestForgeryProtection
    delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller

    attr_reader :model


    module Helpers
      # Renders collection of cells.
      def _collection(name, array, options) # private.
        method = options.delete(:method) || :show
        join   = options.delete(:collection_join)
        array.collect { |model| cell_for(name, *[model, options]).call(method) }.join(join).html_safe
      end

      # Returns cell instance.
      def cell(name, model=nil, options={}, &block) # classic Rails fuzzy API.
        if model.is_a?(Hash) and array = model.delete(:collection)
          return _collection(name, array, model.merge(options))
        end

        cell_for(name, model, options, &block)
      end
    end
    extend Helpers


    class << self
      def property(*names)
        delegates :model, *names # Uber::Delegates.
      end

      include Helpers


      def cell_for(name, *args)
        class_from_cell_name(name).build_cell(*args)
      end

      def class_from_cell_name(name)
        "#{name}_cell".classify.constantize
      end

      def build_cell(*args)
        class_builder.call(*args).new(*args) # Uber::Builder::class_builder.
      end
    end

    # Get nested cell in instance.
    def cell(name, model=nil, options={})
      self.class.cell(name, model, options.merge(controller: parent_controller))
    end


    def initialize(model=nil, options={}) # in Ruby 2: def m(model: nil, controller:nil, **options) that'll make the controller optional.
      # options            = options.clone # DISCUSS: this could be time consuming when rendering many of em.
      @parent_controller = options[:controller] # TODO: filter out controller in a performant way.

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
      template = template_for(options) # TODO: cache template with path/lookup keys.
      content  = template.render(self, options[:locals])

      # TODO: allow other (global) layout dirs.
      with_layout(options, content)
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


    class OutputBuffer < Array
      def encoding
        "UTF-8"
      end

      def <<(string)
        super
      end
      alias_method :safe_append=, :<<
      alias_method :append=, :<<

      def to_s # output_buffer is returned at the end of the precompiled template.
        join
      end
    end
    def output_buffer # called from the precompiled template. FIXME: this is currently not used in Haml.
      OutputBuffer.new # don't cache output_buffer, for every render call we get a fresh one.
    end
    attr_writer :output_buffer # FIXME: where is that used? definitely not in Erbse.
    # TODO: remove output_buffer in favor or returning the string.


    module TemplateFor
      def template_for(options)
        view      = options[:view]
        engine    = options[:template_engine]
        prefixes  = options[:prefixes]

        # we could also pass _prefixes when creating class.templates, because prefixes are never gonna change per instance. not too sure if i'm just assuming this or if people need that.
        self.class.templates[prefixes, view, engine] or raise TemplateMissingError.new(prefixes, view, engine, nil)
      end
    end
    include TemplateFor

    def with_layout(options, content)
      return content unless layout = options[:layout]

      template = template_for(options.merge :view => layout) # we could also allow a different layout engine, etc.
      template.render(self) { content }
    end

    def normalize_options(options, caller) # TODO: rename to #setup_options! to be inline with Trb.
      options = if options.is_a?(Hash)
        options.reverse_merge(:view => state_for_implicit_render(caller))
      else
        {:view => options.to_s}
      end

      options[:template_engine] ||= self.class.template_engine # DISCUSS: in separate method?
      options[:prefixes]        ||= _prefixes

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
      # always include those helpers so we can override the shitty parts.
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::FormTagHelper
    end
  end
end
