module Cell
  class Collection < Array
    def initialize(ary, options, cell_class)
      cells = ary.collect { |model| cell_class.build(model, options) }

      @method = options.delete(:method) # TODO: deprecate :method.
      @join   = options.delete(:collection_join)

      super(cells)
      @options = options
    end

    def call(state=:show)
      # DISCUSS: should we use simple #collect here for speed, timo?
      join(@join) { |cell, i| cell.(@method || state) }.html_safe
    end

    alias to_s call

    def join(separator="", &block)
      return super unless block_given?
      enum_for(:each_with_index).collect(&block).join(separator)
    end
  end
end
