require 'test_helper'

class <%= class_name %>CellTest < ActionController::TestCase
  include Cells::AssertionsHelper
  
  <% for state in states -%>
  test "<%= state %>" do
    html = render_cell(:<%= file_name %>, :<%= state %>)
    #assert_selekt html, "div"
  end
  
  <% end %>
end