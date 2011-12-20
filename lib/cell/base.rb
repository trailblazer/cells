require 'abstract_controller'
require 'cell/builder'
require 'cell/caching'
require 'cell/rendering'
require 'cell/rails3_0_strategy' if Cells.rails3_0?
require 'cell/rails3_1_strategy' if Cells.rails3_1_or_more?
    
module Cell
  class Base < AbstractController::Base
    abstract!
    DEFAULT_VIEW_PATHS = [File.join('app', 'cells')]
    
    extend Builder
    include AbstractController
    include AbstractController::Rendering, Layouts, Helpers, Callbacks, Translation, Logger
    
    include VersionStrategy
    include Rendering
    include Caching
    
    
    class View < ActionView::Base
      def render(*args, &block)
        options = args.first.is_a?(::Hash) ? args.first : {}  # this is copied from #render by intention.
        
        return controller.render(*args, &block) if options[:state] or options[:view]
        super
      end
    end
    
    
    # Called in Railtie at initialization time.
    def self.setup_view_paths!
      self.view_paths = DEFAULT_VIEW_PATHS
    end
    
    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end
  end
end
