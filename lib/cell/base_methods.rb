module Cell
  module BaseMethods
    def self.included(base)
      base.extend ClassMethods
      
      ### DISCUSS: move that to Rails?
      base.class_attribute :default_template_format
      base.default_template_format = :html
    end
    
    module ClassMethods
      def render_cell_for(controller, name, state, opts={})
        create_cell_for(controller, name, opts).render_state(state)
      end
      
      # Creates a cell instance of the class <tt>name</tt>Cell, passing through
      # <tt>opts</tt>.
      def create_cell_for(controller, name, opts={})
        #class_from_cell_name(name).new(controller, opts)
        class_from_cell_name(name).new(controller, opts)
      end
      
      # Return the default view for the given state on this cell subclass.
      # This is a file with the name of the state under a directory with the
      # name of the cell followed by a template extension.
      def view_for_state(state)
        "#{cell_name}/#{state}"
      end

      # Find a possible template for a cell's current state.  It tries to find a
      # template file with the name of the state under a subdirectory
      # with the name of the cell under the <tt>app/cells</tt> directory.
      # If this file cannot be found, it will try to call this method on
      # the superclass.  This way you only have to write a state template
      # once when a more specific cell does not need to change anything in
      # that view.
      def find_class_view_for_state(state)
        return [view_for_state(state)] unless superclass.respond_to?(:find_class_view_for_state)

        superclass.find_class_view_for_state(state) << view_for_state(state)
      end

      # Get the name of this cell's class as an underscored string,
      # with _cell removed.
      #
      # Example:
      #  UserCell.cell_name
      #  => "user"
      def cell_name
        name.underscore.sub(/_cell$/, '')
      end
      
      def class_from_cell_name(cell_name)
        "#{cell_name}_cell".classify.constantize
      end
    end
    
    
    
    
    
    attr_accessor :controller
    attr_reader   :state_name

    def initialize(options={})
      #@controller = controller
      @opts       = options
    end

    def cell_name
      self.class.cell_name
    end

    # Invoke the state method and render the given state.
    def render_state(state, controller=nil)
      @cell       = self
      @state_name = state

      dispatch_state(state)
    end

    # Call the state method.
    def dispatch_state(state)
      send(state)
    end
    
    # Find possible files that belong to the state.  This first tries the cell's
    # <tt>#view_for_state</tt> method and if that returns a true value, it
    # will accept that value as a string and interpret it as a pathname for
    # the view file. If it returns a falsy value, it will call the Cell's class
    # method find_class_view_for_state to determine the file to check.
    #
    # You can override the ::Cell::Base#view_for_state method for a particular
    # cell if you wish to make it decide dynamically what file to render.
    def possible_paths_for_state(state)
      self.class.find_class_view_for_state(state).reverse!
    end
      
  end
end