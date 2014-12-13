# Used in rspec-cells
module Cell
  module TestHelper
    def cell(name, *args)
      ViewModel.cell_for(name, nil, *args)
    end

    def concept(name, *args)
      Concept.cell_for(name, nil, *args)
    end
  end
end