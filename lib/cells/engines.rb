require 'rails/application/railties'

module Cells
  # Now <tt>Rails::Engine</tt>s can contribute to Cells view paths.
  # By default, any 'app/cells' found inside any Engine is automatically included into Cells view paths.
  #
  # You can customize the view paths changing/appending to the <tt>'app/cell_views'</tt> path configuration:
  # 
  #   module MyAwesome
  #     class Engine < Rails::Engine
  #       # loads views from 'cell/views' and NOT from 'app/cells'
  #       config.paths.add 'app/cell_views', :with => 'cell/views'
  # 
  #       # appends 'lib/my_cells_view_path' to this Railtie view path contribution
  #       config.paths['app/cell_views'] << 'lib/my_cells_view_path'
  #     end
  #   end
  # 
  # You can manually specify which Engines will be added to Cell view paths
  # 
  #   Cell::Base.config.view_path_engines = [MyAwesome::Engine]
  # 
  # And even disable the automatic loading
  # 
  #   Cell::Base.config.view_path_engines = false
  # 
  # You can programatically append a Rails::Engine to Cell view path
  # 
  #   Cells.setup do |config|
  #     config.append_engine_view_path!(MyEngine::Engine)
  #   end
  #
  module Engines
    extend VersionStrategy  # adds #registered_engines and #existent_directories_for.
    
    # Appends all <tt>Rails::Engine</tt>s cell-views path to Cell::Base#view_paths
    # 
    # All <tt>Rails::Engine</tt>s specified at <tt>config.view_path_engines</tt> will have its cell-views path appended to Cell::Base#view_paths
    #  
    # Defaults <tt>config.view_path_engines</tt> to all loaded <tt>Rails::Engine</tt>s.
    #
    def self.append_engines_view_paths_for(config)
      return if config.view_path_engines == false

      engines = config.view_path_engines || registered_engines  #::Rails::Application::Railties.engines
      engines.each {|engine| append_engine_view_path!(engine) }
    end

    # Appends a <tt>Rails::Engine</tt> cell-views path to @Cell::Base@
    #
    # The <tt>Rails::Engine</tt> cell-views path is obtained from the <tt>paths['app/cell_views']</tt> configuration.
    # All existing directories specified at cell-views path will be appended do Cell::Base#view_paths
    #
    # Defaults <tt>paths['app/cell_views']</tt> to 'app/cells'
    #
    def self.append_engine_view_path!(engine)
      engine.paths['app/cell_views'] || engine.paths.add('app/cell_views', :with => 'app/cells')
      Cell::Rails.append_view_path(existent_directories_for(engine.paths["app/cell_views"]))
    end
  end
end
