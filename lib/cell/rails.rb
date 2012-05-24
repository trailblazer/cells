require 'cell/rack'

module Cell
  class Rails < Rack
    # When this file is included we can savely assume that a rails environment with caching, etc. is available.
    include ActionController::RequestForgeryProtection
    
    abstract!
    delegate :session, :params, :request, :config, :env, :url_options, :to => :parent_controller
    
    class << self
      def cache_store
        # FIXME: i'd love to have an initializer in the cells gem that _sets_ the cache_store attr instead of overriding here.
        # since i dunno how to do that we'll have this method in rails for now.
        # DISCUSS: should this be in Cell::Rails::Caching ?
        ActionController::Base.cache_store
      end
      
      def cache_configured?
        # DISCUSS: why is it private?
        ActionController::Base.send(:cache_configured?)
      end
      
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
