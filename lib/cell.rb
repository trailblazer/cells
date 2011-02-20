module Cell
  autoload :Caching, 'cell/caching'

  extend ActiveSupport::Concern
  
  DEFAULT_VIEW_PATHS = [
    File.join('app', 'cells'),
    File.join('app', 'cells', 'layouts')
  ]
    
  module ClassMethods
    # Called in Railtie at initialization time.
    def setup_view_paths!
      self.view_paths = self::DEFAULT_VIEW_PATHS
    end
    
    def render_cell_for(controller, name, state, *args)
      cell = create_cell_for(controller, name, *args)  # DISCUSS: we always save options.
      yield cell if block_given?
      
      return cell.render_state(state, *args) if cell.state_accepts_args?(state)
      cell.render_state(state)  # backward-compat.
    end
    
    # Creates a cell instance. Note that this method calls builders which were attached to the
    # class with Cell::Base.build - this might lead to a different cell being returned.
    def create_cell_for(controller, name, *args)
      build_class_for(controller, class_from_cell_name(name), *args).
      new(controller, *args)
    end
    
    # Adds a builder to the cell class. Builders are used in #render_cell to find out the concrete
    # class for rendering. This is helpful if you frequently want to render subclasses according
    # to different circumstances (e.g. login situations) and you don't want to place these deciders in
    # your view code.
    #
    # Passes the opts hash from #render_cell into the block. The block is executed in controller context. 
    # Multiple build blocks are ORed, if no builder matches the building cell is used.
    #
    # Example:
    #
    # Consider two different user box cells in your app.
    #
    #   class AuthorizedUserBox < UserInfoBox
    #   end
    #
    #   class AdminUserBox < UserInfoBox
    #   end
    #
    # Now you don't want to have deciders all over your views - use a declarative builder.
    #
    #   UserInfoBox.build do |opts|
    #     AuthorizedUserBox if user_signed_in?
    #     AdminUserBox if admin_signed_in?
    #   end
    #
    # In your view #render_cell will instantiate the right cell for you now.
    def build(&block)
      builders << block
    end
    
    def build_class_for(controller, target_class, *args)
      target_class.builders.each do |blk|
        res = controller.instance_exec(*args, &blk) and return res
      end
      target_class
    end
    
    def builders
      @builders ||= []
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

    def cell_name # TODO: remove in 3.6.
      controller_path
    end

    # The cell class constant for +cell_name+.
    def class_from_cell_name(cell_name)
      "#{cell_name}_cell".classify.constantize
    end
  end

  module InstanceMethods
    # Computes all possible paths for +state+ by traversing up the inheritance chain.
    def possible_paths_for_state(state)
      self.class.find_class_view_for_state(state).reverse!
    end
    
    def state_accepts_args?(state)
      method(state).arity != 0
    end
  end
end
