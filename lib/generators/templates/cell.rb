class <%= class_name %>Cell < <%= options.base_class %>

<% for action in actions -%>
  def <%= action %>
    render
  end

<% end -%>
end
