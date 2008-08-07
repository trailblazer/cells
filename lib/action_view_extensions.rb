# The Cells plugin defines a number of new methods for ActionView::Base.  These allow
# you to render cells from within normal controller views as well as from Cell state views.
class ActionView::Base
  # Let the ActionView class know that this is being instantiated for cells.
  # This is a hack, but it is required because the assumption that views are
  # located in a 'views' directory is pretty much hardcoded in Rails.
  attr_accessor :for_cells

  # Call a cell state and return its rendered view.
  #
  # ERB example:
  #   <div id="login">
  #     <%= render_cell :user, :login_prompt, :message => "Please login" %>
  #   </div>
  #
  # If you have a <tt>UserCell</tt> cell in <tt>app/cells/user_cell.rb</tt>, which has a
  # <tt>UserCell#login_prompt</tt> method (this is called the <tt>login_prompt</tt>
  # <em>state</em> in Cells terminology), this will call that method and then will
  # find the view <tt>app/cells/user/login_prompt.rhtml</tt> and render it.
  #
  # If this view file looks like this:
  #   <h1><%= @opts[:message] %></h1>
  #   <label>name: <input name="user[name]" /></label>
  #   <label>password: <input name="user[password]" /></label>
  #
  # The resulting view in the controller will be roughly equivalent to:
  #   <div id="login">
  #     <h1><%= "Please login" %></h1>
  #     <label>name: <input name="user[name]" /></label>
  #     <label>password: <input name="user[password]" /></label>
  #   </div>
  def render_cell(name, state, opts = {})
    cell = Cell::Factory.create(controller, name, opts);

    @controller.send :forget_variables_added_to_assigns   # this fixes bug #1, PARTLY.

    return cell.render_state(state)
  end

  ### DISCUSS: to stay for- and backward compatible i decided to introduce the
  #   cells_render method, so we don't have to hurt rails too much.
  #   currently this method hurts rails: it simply prepends a string to the
  #   template path and extends #full_template_path to detect this and set
  #   the appropriate path. i hope someone will rewrite this clean so we don't
  #   have to fiddle around in rails.
  #   thanks to james adam from whom i stole the #full_template_path trick :-)
  def cells_render(options = {})
    return render(options)

    if (template_path = options[:partial])  ### TODO: what about other tpl types?
                                            ### TODO: :template, :cell, ...

      options[:partial] = "cells/"+template_path
    end
    if (template_path = options[:template])
                                            ### TODO: :template, :cell, ...
      options[:template] = "cells/"+template_path
    elsif (template_path = options[:file])
      options[:file] = "cells/"+template_path
    end

    return render(options)
  end

  # Let the ActionView class know that this is being instantiated for cells.
  # This is a hack, but it is required because the assumption that views are
  # located in a 'views' directory is pretty much hardcoded in Rails.
  attr_accessor :for_cells

end
