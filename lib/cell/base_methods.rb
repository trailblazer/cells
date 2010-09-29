module Cell
  module BaseMethods
    
    extend ActiveSupport::Concern
    
    module ClassMethods
      def render_cell_for(controller, name, state, opts={})
        create_cell_for(controller, name, opts).render_state(state) # FIXME: don't let BaseMethods know about controller's API.
      end
      
      # Creates a cell instance.
      def create_cell_for(controller, name, opts={})
        class_from_cell_name(name).new(controller, opts)
      end
      
      # Return the default view path for +state+. Override this if you cell has a differing naming style.
      def view_for_state(state)
        "#{cell_name}/#{state}"
      end

      # Returns all possible view paths for +state+ by invoking #view_for_state on all classes up
      # the inheritance chain.
      def find_class_view_for_state(state)
        return [view_for_state(state)] unless superclass.respond_to?(:find_class_view_for_state)

        superclass.find_class_view_for_state(state) << view_for_state(state)
      end

      # The cell name, underscored with +_cell+ removed.
      def cell_name
        name.underscore.sub(/_cell$/, '')
      end
      
      def class_from_cell_name(cell_name)
        "#{cell_name}_cell".classify.constantize
      end
    end
    
    
    
    
    attr_reader   :state_name

    #def cell_name
    #  self.class.cell_name
    #end

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
    
    # Computes all possible paths for +state+ by traversing up the inheritance chain.
    def possible_paths_for_state(state)
      self.class.find_class_view_for_state(state).reverse!
    end
      
  end
end
