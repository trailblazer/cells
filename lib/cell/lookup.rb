module Cell
  class Lookup
    
    def initialize(controller)
      @controller = controller
    end
    
    # Lookups up a cell by its name
    # Example:
    #
    #   Cell::Lookup.new(self)["name"]
    def [](name)
      ::Cell::Dsl.new(@controller, name)
    end
    
  end
end
