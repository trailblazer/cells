class <%= class_name %>Cell < Cell::Base
<% for action in actions -%>
  def <%= action %>
    render
  end
<% end -%>
end
