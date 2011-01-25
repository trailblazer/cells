class <%= class_name %>Cell < Cell::Rails

<% for action in actions -%>
  def <%= action %>
    render
  end

<% end -%>
end
