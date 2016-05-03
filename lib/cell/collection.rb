module Cell
  class Collection
    def initialize(ary, options, cell_class)
      @method = options.delete(:method) # TODO: deprecate :method.
      @join   = options.delete(:collection_join)

      @ary = ary
      @options = options
      @cell_class = cell_class
    end

    module Call
      def call(state=:show)
        join(@join) { |cell, i| cell.(@method || state) }
      end
    end
    include Call

    alias to_s call

    # Iterate collection and build a cell for each item.
    # The passed block receives that cell and the index.
    # Its return value is captured and joined.
    def join(separator="", &block)
      @ary.each_with_index.collect do |model, i|
        yield @cell_class.build(model, @options), i
      end.
        join(separator)
    end

    module Layout
      def call(*) # WARNING: THIS IS NOT FINAL API.
        blaaaa_layout = @options.delete(:layout) # FIXME: THAT SUCKS.

        content = super # DISCUSS: that could come in via the pipeline argument.
        ViewModel::Layout::External::Render.(content, @ary, blaaaa_layout, @options)
      end
    end
    include Layout

  end
end

# Collection#call
# |> Header#call
# |> Layout#call
