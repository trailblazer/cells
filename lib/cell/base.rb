    # == Basic overview
    #
    # A Cell is the central notion of the cells plugin.  A cell acts as a
    # lightweight controller in the sense that it will assign variables and
    # render a view.  Cells can be rendered from other cells as well as from
    # regular controllers and views (see ActionView::Base#render_cell and
    # ControllerMethods#render_cell)
    #
    # == A render_cell() cycle
    #
    # A typical <tt>render_cell</tt> state rendering cycle looks like this:
    #   render_cell :blog, :newest_article, {...}
    # - an instance of the class <tt>BlogCell</tt> is created, and a hash containing
    #   arbitrary parameters is passed
    # - the <em>state method</em> <tt>newest_article</tt> is executed and assigns instance
    #   variables to be used in the view
    # - Usually the state method will call #render and return
    # - #render will retrieve the corresponding view
    #   (e.g. <tt>app/cells/blog/newest_article.html. [erb|haml|...]</tt>),
    #   renders this template and returns the markup.
    #
    # == Design Principles
    # A cell is a completely autonomous object and it should not know or have to know
    # from what controller it is being rendered.  For this reason, the controller's
    # instance variables and params hash are not directly available from the cell or
    # its views. This is not a bug, this is a feature!  It means cells are truly
    # reusable components which can be plugged in at any point in your application
    # without having to think about what information is available at that point.
    # When rendering a cell, you can explicitly pass variables to the cell in the
    # extra opts argument hash, just like you would pass locals in partials.
    # This hash is then available inside the cell as the @opts instance variable.
    #
    # == Directory hierarchy
    #
    # To get started creating your own cells, you can simply create a new directory
    # structure under your <tt>app</tt> directory called <tt>cells</tt>.  Cells are
    # ruby classes which end in the name Cell.  So for example, if you have a
    # cell which manages all user information, it would be called <tt>UserCell</tt>.
    # A cell which manages a shopping cart could be called <tt>ShoppingCartCell</tt>.
    #
    # The directory structure of this example would look like this:
    #   app/
    #     models/
    #       ..
    #     views/
    #       ..
    #     helpers/
    #       application_helper.rb
    #       product_helper.rb
    #       ..
    #     controllers/
    #       ..
    #     cells/
    #       shopping_cart_cell.rb
    #       shopping_cart/
    #         status.html.erb
    #         product_list.html.erb
    #         empty_prompt.html.erb
    #       user_cell.rb
    #       user/
    #         login.html.erb
    #       layouts/
    #         box.html.erb
    #     ..
    #
    # The directory with the same name as the cell contains views for the
    # cell's <em>states</em>.  A state is an executed method along with a
    # rendered view, resulting in content. This means that states are to
    # cells as actions are to controllers, so each state has its own view.
    # The use of partials is deprecated with cells, it is better to just
    # render a different state on the same cell (which also works recursively).
    #
    # Anyway, <tt>render :partial </tt> in a cell view will work, if the
    # partial is contained in the cell's view directory.
    #
    # As can be seen above, Cells also can make use of helpers.  All Cells
    # include ApplicationHelper by default, but you can add additional helpers
    # as well with the ::Cell::Base.helper class method:
    #   class ShoppingCartCell < ::Cell::Base
    #     helper :product
    #     ...
    #   end
    #
    # This will make the <tt>ProductHelper</tt> from <tt>app/helpers/product_helper.rb</tt>
    # available from all state views from our <tt>ShoppingCartCell</tt>.
    #
    # == Cell inheritance
    #
    # Unlike controllers, Cells can form a class hierarchy.  When a cell class
    # is inherited by another cell class, its states are inherited as regular
    # methods are, but also its views are inherited.  Whenever a view is looked up,
    # the view finder first looks for a file in the directory belonging to the
    # current cell class, but if this is not found in the application or any
    # engine, the superclass' directory is checked.  This continues all the
    # way up until it stops at ::Cell::Base.
    #
    # For instance, when you have two cells:
    #   class MenuCell < ::Cell::Base
    #     def show
    #     end
    #
    #     def edit
    #     end
    #   end
    #
    #   class MainMenuCell < MenuCell
    #     .. # no need to redefine show/edit if they do the same!
    #   end
    # and the following directory structure in <tt>app/cells</tt>:
    #   app/cells/
    #     menu/
    #       show.html.erb
    #       edit.html.erb
    #     main_menu/
    #       show.html.erb
    # then when you call
    #   render_cell :main_menu, :show
    # the main menu specific show.html.erb (<tt>app/cells/main_menu/show.html.erb</tt>)
    # is rendered, but when you call
    #   render_cell :main_menu, :edit
    # cells notices that the main menu does not have a specific view for the
    # <tt>edit</tt> state, so it will render the view for the parent class,
    # <tt>app/cells/menu/edit.html.erb</tt>
    #
    #
    # == Gettext support
    #
    # Cells support gettext, just name your views accordingly. It works exactly equivalent
    # to controller views.
    #
    #   cells/user/user_form.html.erb
    #   cells/user/user_form_de.html.erb
    #
    # If gettext is set to DE_de, the latter view will be chosen.
