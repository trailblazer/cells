module Cell::Base::Concept
  # cell("comment/cell", comment)
  # cell("comment/cell", collection: comments, [:show])
  # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    def self.cell(name, controller, *args, &block) # classic Rails fuzzy API.
      if args.first.is_a?(Hash) and array = args.first[:collection]
        return collection(name, controller, array) # from ViewModel.
      end

      cell_for(name, controller, *args, &block)
    end

    def self.collection(name, controller, array, method=:show, builder=self)
      # FIXME: this is the problem in Concept cells, we don't wanna call Cell::Rails.cell_for here.
      array.collect { |model| builder.cell_for(name, controller, model).call(method) }.join("\n").html_safe
    end

  def self.cell_for(name, controller, *args)
    Cell::Builder.new(name.classify.constantize, controller).call(controller, *args)
  end


  module Naming
    module ClassMethods
      def controller_path
        # TODO: cache on class level
        # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
        # applies to Comment::Cell, Comment::Cell::Form, etc.
        name.sub(/::Cell/, '').underscore unless anonymous?
      end
    end
  end

  def self.included(base)
    base.extend Naming::ClassMethods # TODO: separate inherit_view
    base.self_contained!
    base.send :include, Cell::Rails::ViewModel

    base.send :include, Rendering
  end


  # DISCUSS: experimental, allows to render layouts from the partial view directory instead of a global one.
  module Rendering
    def view_renderer
      @_view_renderer ||= Renderer.new(lookup_context)
    end


    def _normalize_options(options) # FIXME: for rails 3.1, only. in 3.2+ it's _normalize_layout.
      super

      if options[:layout]
        options[:layout].sub!("layouts/", "")
      end
    end
  end

  class Renderer < ActionView::Renderer
    def _template_renderer #:nodoc:
      @_template_renderer ||= TemplateRenderer.new(@lookup_context)
    end


    class TemplateRenderer < ActionView::TemplateRenderer
      def render(context, options)
        @options = options
        super
      end

      def find_layout(layout, keys)
        resolve_layout(layout, keys, [formats.first])
      end

      def resolve_layout(layout, keys, formats)
        details = @details ? @details.dup : {} # FIXME: provide the entire Renderer layer here. this is to make it compatible with Rails 3.1.
        details[:formats] = formats

        case layout
        when String
          find_args = [layout, @options[:prefixes], false, keys, details]
          find_args = [layout, @options[:prefixes], false, keys] if Cell.rails_version.~ 3.1
          find_template(*find_args)
        when Proc
          resolve_layout(layout.call, keys, formats)
        else
          layout
        end
      end
    end
  end
end