module Cell
  autoload :Caching, 'cell/caching'
  
  extend ActiveSupport::Concern
  
  DEFAULT_VIEW_PATHS = [File.join('app', 'cells')]
  
  module ClassMethods
    # Called in Railtie at initialization time.
    def setup_view_paths!
      self.view_paths = self::DEFAULT_VIEW_PATHS
    end
    
    
  end
end
