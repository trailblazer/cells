module Cell
  class Collection
    def initialize(ary, options, cell_class)
      options.delete(:collection)

      @ary        = ary
      @options    = options    # these options are "final" and will be identical for all collection cells.
      @cell_class = cell_class
    end

    module Call
      def call(method=:show)
        join('') { |cell, i| cell.(method) }
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
        cell = @cell_class.build(model, @options)
        block_given? ? yield(cell, i) : cell
      end.join(separator)
    end

    module Layout
      def call(*) # WARNING: THIS IS NOT FINAL API.
        layout = @options.delete(:layout) # we could also override #initialize and that there?

        content = super # DISCUSS: that could come in via the pipeline argument.
        ViewModel::Layout::External::Render.(content, @ary, layout, @options)
      end
    end
    include Layout
  end
end

# Collection#call
# |> Header#call
# |> Layout#call
