class TestCell < Cell::Base

  #def view_for_state(state)    
  #  RAILS_ROOT+"/vendor/plugins/cells/test/views/#{state}.html.erb"
  #end

  def direct_output
    "<h9>this state method doesn't render a template but returns a string, which is great!</h9>"
  end

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

  def state_with_link_to
    return
  end

  def state_with_not_included_helper_method
  end
  
end
