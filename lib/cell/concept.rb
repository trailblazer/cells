# TODO: deprecate parent_controller, ViewModel
class Cell::Concept < Cell::ViewModel
  abstract!
  self.view_paths = "app/concepts"

  # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
  class << self
    def cell_for(name, controller, *args)
      Cell::Builder.new(name.classify.constantize, controller).call(controller, *args)
    end

    def controller_path
      # TODO: cache on class level
      # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
      # applies to Comment::Cell, Comment::Cell::Form, etc.
      name.sub(/::Cell/, '').underscore unless anonymous?
    end
  end

  def concept(name, *args, &block)
    self.class.cell(name, parent_controller, *args, &block)
  end

  self_contained!

  # DISCUSS: experimental, allows to render layouts from the partial view directory instead of a global one.
  module Rendering
    def view_renderer
      @_view_renderer ||= Renderer.new(lookup_context)
    end

    if Cell.rails_version >= 3.2
      def _normalize_layout(value) # 3.2+
        value
      end
    else
      def _normalize_options(options) # FIXME: for rails 3.1, only. in 3.2+ it's _normalize_layout.
        super

        if options[:layout]
          options[:layout].sub!("layouts/", "")
        end
      end
    end
  end

  class Renderer < ActionView::Renderer
    def render_template(context, options) # Rails 4.0 # FIXME: make that simpler to override in rails core.
      TemplateRenderer.new(@lookup_context).render(context, options)
    end

    def _template_renderer # Rails 3.x
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
  end # Rendering

  include Rendering
end