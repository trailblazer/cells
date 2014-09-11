# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class

# TODO: warn when using ::property but not passing in model in constructor.
require 'tilt'
require 'uber/delegates'
require 'cell/templates'

module Cell
  class ViewModel < AbstractController::Base
    abstract!

    extend Uber::InheritableAttr
    inheritable_attr :view_paths

    self.view_paths = "app/cells"

    require 'cell/base/prefixes'
    include Base::Prefixes
    require 'cell/base/self_contained'
    extend Base::SelfContained
    include Caching
    include Cell::DSL # TODO: dunno, this sucks.


    extend Builder::ClassMethods

    class Builder < Cell::Builder # TODO: merge with C:Builder.
      def run_builder_block(block, controller, *args) # DISCUSS: do we _want_ that?
        super(block, *args)
      end
    end


    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end

    include ActionController::RequestForgeryProtection
    delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller


    extend Uber::Delegates

    attr_reader :model


    module Helpers
      # DISCUSS: highest level API method. add #cell here.
      def collection(name, controller, array, options=nil)
        method = :show

        unless options
          return array.collect { |model| cell_for(name, *[controller, model]).call(method) }.join("\n").html_safe
        end
        # FIXME: this is the problem in Concept cells, we don't wanna call Cell::Rails.cell_for here.
        array.collect { |model| cell_for(name, *[controller, model, options]).call(method) }.join("\n").html_safe
      end

      # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
      def cell(name, controller, *args, &block) # classic Rails fuzzy API.
        if args.first.is_a?(Hash) and array = args.first[:collection]
          return collection(name, controller, array, args[1])
        end

        cell_for(name, controller, *args, &block)
      end
    end
    extend Helpers # FIXME: do we really need ViewModel::cell/::collection ?


    class << self
      def property(*names)
        delegates :model, *names # Uber::Delegates.
      end

      include Helpers


      def cell_for(name, controller, *args)
        Builder.new(class_from_cell_name(name), controller).call(controller, *args) # use Cell::Rails::Builder.
      end

      def class_from_cell_name(name)
        "#{name}_cell".classify.constantize
      end
    end

    def cell(name, *args)
      self.class.cell(name, parent_controller, *args)
    end


    def initialize(controller, model=nil, options={})
      @parent_controller = controller # TODO: this is removed in 4.0.

      @model = model
        #create_twin(model, options)
    end
    attr_reader :parent_controller
    alias_method :controller, :parent_controller


    # render :show
    def render(options={})
      options = options_for(options, caller) # TODO: call render methods with call(:show), call(:comments) instead of directly #comments?

      render_to_string(options)
    end

    def render_to_string(options)
      template = template_for(options[:view]) # TODO: cache template with path/lookup keys.
      content  = template.render(self)

      # TODO: allow other (global) layout dirs.
      with_layout(options[:layout], content)
    end


    # Invokes the passed state (defaults to :show) by using +render_state+. This will respect caching.
    # Yields +self+ (the cell instance) to an optional block.
    def call(state=:show)
      # it is ok to call to_s.html_safe here as #call is a defined rendering method.
      # DISCUSS: IN CONCEPT: render( view: implicit_state)
      content = render_state(state)
      yield self if block_given?
      content.to_s.html_safe
    end

  private

    def template_for(view, formats=[:haml])
      base = self.class.view_paths

      Templates.new[base, _prefixes, view, formats] or raise
    end

    def with_layout(layout, content)
      return content unless layout

      template = template_for(layout)
      template.render(self) { content }
    end

    def options_for(options, caller)
      if options.is_a?(Hash)
        options.reverse_merge(:view => state_for_implicit_render(caller)) # TODO: test implicit render!
      else
        {:view => options.to_s}
      end
    end

    def state_for_implicit_render(caller)
      caller[0].match(/`(\w+)/)[1]
    end

    # def implicit_state
    #   controller_path.split("/").last
    # end


    # FIXME: this module is to fix a design flaw in Rails 4.0. the problem is that AV::UrlHelper mixes in the wrong #url_for.
    # if we could mix in everything else from the helper except for the #url_for, it would be fine.
    # FIXME: fix that in rails core.
    if Cell.rails_version.~("4.0", "4.1")
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
  end
end