module Cell
  # Contains all methods for dynamically building a cell instance by using decider blocks.
  module Builder
    # Creates a cell instance. Note that this method calls builders which were attached to the
    # class with Cell::Base.build - this might lead to a different cell being returned.
    def create_cell_for(name, *args)
      class_from_cell_name(name).build_for(*args)
    end
    
    def build_for(*args)  # DISCUSS: remove?
      build_class_for(*args).
      create_cell(*args)
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
    
    # Override this if you want to receive arguments right in the cell constructor.
    def create_cell(*args)
      new
    end
    
  private
    def build_class_for(*args)
      builders.each do |blk|
        klass = run_builder_block(blk, *args) and return klass
      end
      self
    end
    
    def run_builder_block(block, *args)
      block.call(*args)
    end
    
    def builders
      @builders ||= []
    end
  end
end
