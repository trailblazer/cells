class MyTestCell < Cell::Base

  

  def needs_view
    @instance_variable_one = "yeah"
    nil
  end

  def another_rendering_state
    @instance_variable_one = "go"

    return
  end

  def setting_state
    @reset_me = '<p id="ho">ho</p>'
    return
  end

  def reset_state
    return
  end

  

  def state_with_not_included_helper_method
  end
  
end
