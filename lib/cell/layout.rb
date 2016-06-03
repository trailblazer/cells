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

    private
      def process_options!(options)
        options[:layout] ||= self.class.layout_name
        super
      end

      def render_to_string(options, &block)
        with_layout(options, super)
      end

      def with_layout(options, content)
        return content unless layout = options[:layout]

        render_layout(layout, options, content)
      end

      def render_layout(name, options, content)
        template = find_template(options.merge view: name) # we could also allow a different layout engine, etc.
        render_template(template, options) { content }
      end

      # Allows using a separate layout cell which will wrap the actual content.
      # Use like cell(..., layout: Cell::Layout)
      #
      # Note that still allows the `render layout: :application` option.
      module External
        def call(*)
          content = super
          Render.(content, model, @options[:layout], self, @options)
        end

        Render = ->(content, model, layout, content_cell, options) do # WARNING: THIS IS NOT FINAL API.
          return content unless layout # TODO: test when invoking cell without :layout.

          # DISCUSS: should we allow instances, too? we could cache the layout cell.
          layout.new(model, context: options[:context], content_cell: content_cell).(&lambda { content })
        end

        module Content
          def content_block(part)
            return @options[:content_cell].send(part) if @options[:content_cell].respond_to?(part)
            yield if block_given?
          end
        end # Content
      end # External
    end
  end
end
