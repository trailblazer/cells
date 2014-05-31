class <%= class_name %>::Cell < Cell::Concept
<% for action in actions -%>
  def <%= action %>
    render
  end
<% end -%>
end
