module Cell
  class ViewModel
    # Set the layout per cell class. This is used in #render calls. Gets inherited to subclasses.
    module Layout
      def self.included(base)
        base.extend ClassMethods
        base.inheritable_attr :layout_name
      end

      module ClassMethods
        def layout(name)
          self.layout_name = name
        end
      end

      def process_options!(options)
        options[:layout] ||= self.class.layout_name
        super
      end

      # Allows using a separate layout cell which will wrap the actual content.
      # Use like cell(..., layout: Cell::Layout)
      module External
        def call(*)
          content = super
          Render.(content, model, @options[:layout], @options)
        end

        Render = ->(content, model, layout, options) do # WARNING: THIS IS NOT FINAL API.
          return content unless layout = layout # TODO: test when invoking cell without :layout.

          # DISCUSS: should we allow instances, too? we could cache the layout cell.
          layout.new(model, context: options[:context]).(&lambda { content })
        end
      end # External
    end
  end
end
