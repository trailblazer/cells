require 'cell/base'

module Cell
  class Rails < Base
    include ActionController::RequestForgeryProtection
    
    abstract!
    
    module Metal
      delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller
    end
    
    include Metal
    
    attr_reader :parent_controller
    
    def initialize(parent_controller)
      super()
      @parent_controller = parent_controller
    end
  end
end
