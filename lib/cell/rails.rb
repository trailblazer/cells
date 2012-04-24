require 'cell/rack'

module Cell
  class Rails < Rack
    include ActionController::RequestForgeryProtection
    
    abstract!
    delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller
    
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
