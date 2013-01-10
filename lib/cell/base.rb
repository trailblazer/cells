require 'abstract_controller'
require 'cell/builder'
require 'cell/caching'
require 'cell/rendering'

module Cell
  def self.rails3_0?
    ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR == 0
  end
  
  def self.rails3_1_or_more?
    ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 1
  end
  
  def self.rails3_2_or_more?  # FIXME: move to tests.
    ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 2
  end

  def self.rails4_0_or_more?  # FIXME: move to tests.
    ::ActionPack::VERSION::MAJOR == 4
  end
  
  
  class Base < AbstractController::Base
    abstract!
    DEFAULT_VIEW_PATHS = [File.join('app', 'cells')]
    
    extend Builder
    include AbstractController
    include AbstractController::Rendering, Layouts, Helpers, Callbacks, Translation, Logger
    
    require 'cell/rails3_0_strategy' if Cell.rails3_0?
    require 'cell/rails3_1_strategy' if Cell.rails3_1_or_more?
    require 'cell/rails4_0_strategy' if Cell.rails4_0_or_more?
    include VersionStrategy
    include Rendering
    include Caching
    
    class View < ActionView::Base
      def self.prepare(modules)
        # TODO: remove for 4.0 if PR https://github.com/rails/rails/pull/6826 is merged.
        Class.new(self) do  # DISCUSS: why are we mixing that stuff into this _anonymous_ class at all? that makes things super complicated.
          include *modules.reverse
        end
      end
      
      def render(*args, &block)
        options = args.first.is_a?(::Hash) ? args.first : {}  # this is copied from #render by intention.
        
        return controller.render(*args, &block) if options[:state] or options[:view]
        super
      end
    end
    
    
    def self.view_context_class
      @view_context_class ||= begin
        Cell::Base::View.prepare(helper_modules)
      end
    end
      
    # Called in Railtie at initialization time.
    def self.setup_view_paths!
      self.view_paths = self::DEFAULT_VIEW_PATHS
    end
    
    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end
  end
end
