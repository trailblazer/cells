module Cell
  # The Cell Factory manages all cell instantiation.  It is called by
  # ActionView::Base#render_cell.
  #
  # The Cell Factory might be removed in future releases.
  class Factory
    def self.create(controller, cell_name, opts={})
      Base.class_from_cell_name(cell_name).new(controller, cell_name, opts)
    end
  end
end
