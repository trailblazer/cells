require 'cell/base'

module Cell
  class Rails < Base
    include ActionController::RequestForgeryProtection
    
    abstract!
    
    module Metal
      delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller
    end
    
    include Metal
    
    
    class << self
      def create_cell(controller, *args)
        new(controller)
      end
      
    private
      # Run builder block in controller instance context.
      def run_builder_block(block, controller, *args)
        controller.instance_exec(*args, &block)
      end
      
      def render_cell_state(cell, state, *args)
        args.shift  # remove the controller instance.
        cell.render_state(state, *args)
      end
    end
    
    attr_reader :parent_controller
    
    def initialize(parent_controller)
      super()
      @parent_controller = parent_controller
    end
  end
  
  class Rack < Base
    attr_reader :request
    delegate :session, :params, :to => :request
    
    def initialize(request)
      super()
      @request = request
    end
  end
end
