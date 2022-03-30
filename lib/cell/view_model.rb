require "uber/delegates"

module Cell
  class ViewModel
    extend Abstract
    abstract!

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
    extend Util

    def self.controller_path
      @controller_path ||= util.underscore(name.sub(/Cell$/, ''))
    end

    attr_reader :model

    module Helpers
      # Constantizes name if needed, call builders and returns instance.
      def cell(name, *args, &block) # classic Rails fuzzy API.
        constant = name.is_a?(Class) ? name : class_from_cell_name(name)
        constant.(*args, &block)
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
      def call(model=nil, options={}, &block)
        if model.is_a?(Hash) and array = model[:collection]
          return Collection.new(array, model.merge(options), self)
        end

        build(model, options)
      end

      alias build new # semi-public for Cell::Builder

    private
      def class_from_cell_name(name)
        util.constant_for("#{name}_cell")
      end
    end

    # Build nested cell in instance.
    def cell(name, model=nil, options={})
      context = Context[options[:context], self.context]

      self.class.cell(name, model, options.merge(context: context))
    end

    def initialize(model=nil, options={})
      setup!(model, options)
    end

    def context
      @options[:context]
    end

    # DISCUSS: we could use the same mechanism as TRB::Skills here for speed at runtime?
    class Context# < Hash
      # Only dup&merge when :context was passed in parent.cell(context: ..)
      # Otherwise we can simply pass on the old context.
      def self.[](options, context)
        return context unless options
        context.dup.merge(options) # DISCUSS: should we create a real Context object here, to make it overridable?
      end
    end

    module Rendering
      # Invokes the passed method (defaults to :show) while respecting caching.
      # In Rails, the return value gets marked html_safe.
      def call(state=:show, *args, **kws, &block)
        content = render_state(state, *args, **kws, &block)
        content.to_s
      end

      # Since 4.1, you get the #show method for free.
      def show(&block)
        render(&block)
      end

      # render :show
      def render(options={}, &block)
        options = normalize_options(options)
        render_to_string(options, &block)
      end

    private
      def render_to_string(options, &block)
        template = find_template(options)
        render_template(template, options, &block)
      end

      def render_state(*args, **kws, &block)
        __send__(*args, **kws, &block) # Ruby 2.7+
      end

      def render_template(template, options, &block)
        template.render(self, options[:locals], &block) # DISCUSS: hand locals to layout?
      end

      module RubyPre2_7_RenderState
        def render_state(*args, **kws, &block)
          args = args + [kws] if kws.any?
          __send__(*args, &block)
        end
      end
    end

    include Rendering
    include Rendering::RubyPre2_7_RenderState if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7.0')
    include Inspect

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
      caller(3, 1)[0].match(/`(\w+)/)[1]
    end

    include Layout
  end
end
