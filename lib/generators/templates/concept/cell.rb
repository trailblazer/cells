class <%= class_name %>::Cell < <%= options.base_cell_class %>
  include Concept

<% for action in actions -%>
  def <%= action %>
    render
  end
<% end -%>
end
