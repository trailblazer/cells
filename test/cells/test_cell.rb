class TestCell < Cell::Base

  

  def needs_view
    @instance_variable_one = "yeah"
    render
  end

  def another_rendering_state
    @instance_variable_one = "go"
    render
  end

  def setting_state
    @reset_me = '<p id="ho">ho</p>'
    render
  end

  def reset_state
    render
  end

  

  def state_with_not_included_helper_method
    render
  end
  
  
  def state_using_params
    params[:my_param].to_s
  end
end
