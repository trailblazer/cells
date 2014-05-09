module Cell::Base::Concept
  def self.cell(name, controller, *args)
    Cell::Builder.new(name.classify.constantize, controller).cell_for(controller, *args)
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
        details = @details.dup
        details[:formats] = formats

        case layout
        when String
          find_template(layout, @options[:prefixes], false, keys, details)
        when Proc
          resolve_layout(layout.call, keys, formats)
        else
          layout
        end
      end
    end
  end
end