class CellsTestOneCell < Cell::Base

  def super_state
    @my_class = self.class.to_s
    return
  end

  def instance_view
  end

  def view_for_state(state)
    if state.to_s == 'instance_view'
      RAILS_ROOT+"/vendor/plugins/cells/app/cells/cells_test_one/instance_view.html.erb"
    end
  end

  def state_with_no_view
  end

end
