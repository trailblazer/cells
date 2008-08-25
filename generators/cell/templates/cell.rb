class <%= class_name %>Cell < Cell::Base
<% for action in actions -%>
  def <%= action %>
    nil
  end
<% end -%>
end
