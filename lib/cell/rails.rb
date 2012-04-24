require 'cell/base'

module Cell
  class Rack < Base
    attr_reader :request
    delegate :session, :params, :to => :request
    
    class << self
      # DISCUSS: i don't like these class methods. maybe a RenderingStrategy?
      def create_cell(request, *args) # defined in Builder.
        new(request)
      end
      
      def render_cell_state(cell, state, *args) # defined in Rendering.
        args.shift  # remove the request instance.
        super
      end
    end
    
    def initialize(request)
      super()
      @request = request
    end
  end
  
  class Rails < Rack
    include ActionController::RequestForgeryProtection
    
    abstract!
    
    module Metal
      delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller
    end
    
    include Metal
    
    
    class << self
    private
      # Run builder block in controller instance context.
      def run_builder_block(block, controller, *args)
        controller.instance_exec(*args, &block)
      end
    end
    
    attr_reader :parent_controller
    
    def initialize(parent_controller)
      super
      @parent_controller = parent_controller
    end
  end
  
  
end
