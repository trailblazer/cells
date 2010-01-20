class CellsTestOneCell < Cell::Base

  def super_state
    @my_class = self.class.to_s
    return
  end

  def instance_view
  end

  def view_for_state(state)
    if state.to_s == 'instance_view'
      return 'cells_test_one/renamed_instance_view'
    end
  end

  def state_with_no_view
  end

end
