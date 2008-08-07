module Cell
  # These ControllerMethods are automatically added to all Controllers when
  # the cells plugin is loaded.
  module ControllerMethods

    # Equivalent to ActionController#render_to_string, except with Cells
    # rather than regular templates.
    def render_cell_to_string(name, state, opts={})
      cell = Cell::Factory.create(self, name, opts);

      return cell.render_state(state)
    end
  end
end



