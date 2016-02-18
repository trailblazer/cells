module Cell
  class ViewModel
    extend Abstract
    abstract!

    def controller_path
      self.class.controller_path
    end

    extend Uber::InheritableAttr
    extend Uber::Delegates

    inheritable_attr :view_paths
    self.view_paths = ["app/cells"]

    class << self
      def templates
        @templates ||= Templates.new # note: this is shared in subclasses. do we really want this?
      end
    end

    include Prefixes
    extend SelfContained
    extend Util

    def self.controller_path
      @controller_path ||= util.underscore(name.sub(/Cell$/, ''))
    end

    attr_reader :model

    module Helpers
      # Constantizes name, call builders and returns instance.
      def cell(name, *args) # classic Rails fuzzy API.
        options = args.extract_options!
        controller = options[:controller]
        args << options
        class_from_cell_name(name, controller).(*args)
      end
    end
    extend Helpers

    class << self
      def property(*names)
        delegates :model, *names # Uber::Delegates.
      end

      # Public entry point. Use this to instantiate cells with builders.
      #
      #   SongCell.(@song)
      #   SongCell.(collection: Song.all)
      def call(model=nil, options={})
        if model.is_a?(Hash) and array = model.delete(:collection)
          return CellCollection.new(array, model.merge(options), self)
        end

        build(model, options)
      end

      alias build new # semi-public for Cell::Builder

    private
      def class_from_cell_name(name, controller)
        @cell_class ||= begin
          supports_path = controller.supports_path?
          routes  = controller.respond_to?(:_routes)  && controller._routes
          helpers = controller.respond_to?(:_helpers) && controller._helpers

          Class.new("#{name}_cell".camelize.constantize) do
            if routes
              include routes.url_helpers(supports_path)
              include routes.mounted_helpers
            end

            if helpers
              include helpers
            end
          end
        end
      end
    end

    # Get nested cell in instance.
    def cell(name, model=nil, options={})
      self.class.cell(name, model, options.merge(controller: parent_controller))
    end

    def initialize(model=nil, options={})
      @parent_controller = options[:controller] # TODO: filter out controller in a performant way.

      setup!(model, options)
    end
    attr_reader :parent_controller
    alias_method :controller, :parent_controller

    module Rendering
      # Invokes the passed method (defaults to :show) while respecting caching.
      # In Rails, the return value gets marked html_safe.
      def call(state=:show, *args)
        content = render_state(state, *args)
        content.to_s
      end

      # render :show
      def render(options={})
        options = normalize_options(options)
        render_to_string(options)
      end

    private
      def render_to_string(options)
        template = find_template(options)
        content  = render_template(template, options)

        # TODO: allow other (global) layout dirs.
        with_layout(options, content)
      end

      def render_state(*args)
        __send__(*args)
      end

      def with_layout(options, content)
        return content unless layout = options[:layout]

        template = find_template(options.merge view: layout) # we could also allow a different layout engine, etc.

        render_template(template, options) { content }
      end

      def render_template(template, options, &block)
        template.render(self, options[:locals], &block) # DISCUSS: hand locals to layout?
      end
    end

    include Rendering

    def to_s
      call
    end
    include Caching

  private
    attr_reader :options

    def setup!(model, options)
      @model   = model
      @options = options
      # or: create_twin(model, options)
    end

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
      OutputBuffer.new # don't cache output_buffer, for every #render call we get a fresh one.
    end

    module TemplateFor
      def find_template(options)
        template_options = template_options_for(options) # imported by Erb, Haml, etc.
        # required options: :template_class, :suffix. everything else is passed to the template implementation.

        view      = options[:view]
        prefixes  = options[:prefixes]
        suffix    = template_options.delete(:suffix)
        view      = "#{view}.#{suffix}"

        template_for(prefixes, view, template_options) or raise TemplateMissingError.new(prefixes, view)
      end

      def template_for(prefixes, view, options)
        # we could also pass _prefixes when creating class.templates, because prefixes are never gonna change per instance. not too sure if i'm just assuming this or if people need that.
        # Note: options here is the template-relevant options, only.
        self.class.templates[prefixes, view, options]
      end
    end
    include TemplateFor

    def normalize_options(options)
      options = if options.is_a?(Hash)
        options[:view] ||= state_for_implicit_render(options)
        options
      else
        {view: options.to_s}
      end

      options[:prefixes] ||= _prefixes

      process_options!(options)
      options
    end

    # Overwrite #process_options in included feature modules, but don't forget to call +super+.
    module ProcessOptions
      def process_options!(options)
      end
    end
    include ProcessOptions

    # Computes the view name from the call stack in which `render` was invoked.
    def state_for_implicit_render(options)
      _caller = RUBY_VERSION < "2.0" ? caller(3) : caller(3, 1) # TODO: remove case in 5.0 when dropping 1.9.
      _caller[0].match(/`(\w+)/)[1]
    end

    include Layout
  end
end
