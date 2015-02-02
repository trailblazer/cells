# Used in rspec-cells, etc.
module Cell
  module Testing
    def cell(name, *args)
      ViewModel.cell_for(name, controller, *args)
    end

    def concept(name, *args)
      Concept.cell_for(name, controller, *args)
    end

    def controller
    end
  end
end