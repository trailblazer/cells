module Cell
  class Dsl
    
    def initialize(controller, name)
      @controller = controller
      @name = name
    end
    
    # Returns the cell content by delegating the invocation to render_cell_for
    def method_missing(sym, opts = {}, &block)
      ::Cell::Base.render_cell_for(@controller, @name, sym, opts, &block)
    end
    
  end
end
