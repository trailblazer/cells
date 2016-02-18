module Cell
  class CellCollection

    attr_reader :collection, :cells
    alias_method :model, :collection

    def initialize(collection=nil, options={}, klass)
      @collection = collection
      @collection_join = options.delete(:collection_join)
      @cells = collection.collect { |model| klass.build(model, options) }
    end

    def call(state=:show, *args)
      content = call_sells(state, *args)
      content.join @collection_join
    end

    def to_s
      call
    end

  private
    # Calls collection of cells.
    def call_sells(state, *args) # private.
      cells.collect { |cell| cell.call(state, *args) }
    end
  end
end
