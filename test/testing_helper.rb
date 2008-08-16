module CellsTestMethods
  
  def assert_selekt(content, *args)
    assert_select(HTML::Document.new(content).root, *args)
  end

  def setup
    @controller = CellTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.request = @request
    @controller.response = @response
  end
  
  def self.views_path
    File.dirname(__FILE__) + '/views/'
  end
end



class CellTestController < ApplicationController
  def rescue_action(e) raise e end

  def render_cell_state
    cell  = params[:cell]
    state = params[:state]

    render :text => render_cell_to_string(cell, state)
  end

  def call_render_cell_with_strings
    static = render_cell_to_string("test", "direct_output")
    render :text => static
  end

  def call_render_cell_with_syms
    static = render_cell_to_string(:test, :direct_output)
    render :text => static
  end

  def call_render_cell_with_state_view
    render :text => render_cell_to_string(:test, :rendering_state)
    return
  end

  def render_view_with_render_cell_invocation
    render :file => "#{RAILS_ROOT}/vendor/plugins/cells/test/views/view_with_render_cell_invocation.html.erb"
    return
  end

  def render_just_one_view_cell
    static = render_cell_to_string("just_one_view", "some_state")
    render :text => static
  end

  def render_reset_bug
    static = render_cell_to_string("test", "setting_state")
    static += render_cell_to_string("test", "reset_state")
    render :text => static
  end
  
  
  def render_state_with_link_to
    static = render_cell_to_string("test", "state_with_link_to")
    render :text => static
  end

end
