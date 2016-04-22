module Cell
  class Collection
    def initialize(ary, options, cell_class)


      @method = options.delete(:method) # TODO: deprecate :method.
      @join   = options.delete(:collection_join)

      @ary = ary
      @options = options
      @cell_class = cell_class
    end

    def call(state=:show)
      content = []
      @ary.each_with_index do |model, i|
        content << @cell_class.build(model, @options).(@method || state)
      end

      content.
        join(@join).html_safe

      # DISCUSS: should we use simple #collect here for speed, timo?

      # cells = ary.collect { |model| cell_class.build(model, options).(@method || state) }

      # join(@join) { |cell, i| cell.(@method || state) }.html_safe
    end

    alias to_s call

    def join(separator="", &block)
      content = []
      @ary.each_with_index do |model, i|
        content << yield(@cell_class.build(model, @options), i)
      end

      content.
        join(separator)
    end
  end
end
