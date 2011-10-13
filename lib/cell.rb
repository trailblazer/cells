module Cell
  autoload :Caching, 'cell/caching'

  extend ActiveSupport::Concern
  
  DEFAULT_VIEW_PATHS = [File.join('app', 'cells')]
  
  module ClassMethods
    # Called in Railtie at initialization time.
    def setup_view_paths!
      self.view_paths = self::DEFAULT_VIEW_PATHS
    end
    
    # Main entry point for #render_cell.
    def render_cell_for(controller, name, state, *args)
      cell = create_cell_for(controller, name, *args)
      yield cell if block_given?
      
      cell.render_state(state, *args)
    end
    
    # Creates a cell instance. Note that this method calls builders which were attached to the
    # class with Cell::Base.build - this might lead to a different cell being returned.
    def create_cell_for(controller, name, *args)
      class_from_cell_name(name).build_for(controller, *args)
    end
    
    def build_for(controller, *args)
      build_class_for(controller, *args).
      new(controller)
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
    
    # The cell class constant for +cell_name+.
    def class_from_cell_name(cell_name)
      "#{cell_name}_cell".classify.constantize
    end
    
  protected
    def build_class_for(controller, *args)
      builders.each do |blk|
        klass = controller.instance_exec(*args, &blk) and return klass
      end
      self
    end
    
    def builders
      @builders ||= []
    end
  end
end
