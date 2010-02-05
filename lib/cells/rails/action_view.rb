# encoding: utf-8

# The Cells plugin defines a number of new methods for ActionView::Base.  These allow
# you to render cells from within normal controller views as well as from Cell state views.
module Cells
  module Rails
    module ActionView
      # Call a cell state and return its rendered view.
      #
      # ERB example:
      #   <div id="login">
      #     <%= render_cell :user, :login_prompt, :message => "Please login" %>
      #   </div>
      #
      # If you have a <tt>UserCell</tt> cell in <tt>app/cells/user_cell.rb</tt>, which has a
      # <tt>UserCell#login_prompt</tt> method, this will call that method and then will
      # find the view <tt>app/cells/user/login_prompt.html.erb</tt> and render it. This is
      # called the <tt>:login_prompt</tt> <em>state</em> in Cells terminology.
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
        cell = ::Cell::Base.create_cell_for(@controller, name, opts)
        cell.render_state(state)
      end
    end
  end
end
