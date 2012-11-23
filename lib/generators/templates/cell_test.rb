require 'test_helper'

<% module_namespacing do -%>
class <%= class_name %>CellTest < Cell::TestCase
<% for state in @states -%>
  test "<%= state %>" do
    invoke :<%= state %>
    assert_select "p"
  end
  
<% end %>
end
<% end -%>
