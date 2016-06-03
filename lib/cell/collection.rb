module Cell
  class Collection
    def initialize(ary, options, cell_class)
      options.delete(:collection)
      @method     = options.delete(:method)           # TODO: remove in 5.0.
      @join       = options.delete(:collection_join)  # TODO: remove in 5.0.

      @ary        = ary
      @options    = options
      @cell_class = cell_class

      deprecate_options!
    end

    def deprecate_options! # TODO: remove in 5.0.
      warn "[Cells] The :method option is deprecated. Please use `call(method)` as documented here: http://trailblazer.to/gems/cells/api.html#collection" if @method
      warn "[Cells] The :collection_join option is deprecated. Please use `join(\"<br>\")` as documented here: http://trailblazer.to/gems/cells/api.html#collection" if @collection_join
    end

    module Call
      def call(state=:show)
        join(@join) { |cell, i| cell.(@method || state) }
      end
    end
    include Call

    def to_s
      call
    end

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
        layout = @options.delete(:layout) # we could also override #initialize and that there?

        content = super # DISCUSS: that could come in via the pipeline argument.
        ViewModel::Layout::External::Render.(content, @ary, layout, self, @options)
      end
    end
    include Layout

  end
end

# Collection#call
# |> Header#call
# |> Layout#call
