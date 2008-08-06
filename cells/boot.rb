# Add the code path of 'cells' to the default paths of a Plugin.  This
# gets copied to the list of paths of the Plugin when it's instantiated,
# so be sure to load the Cells Plugin before loading any Plugins that
# have a 'cells' directory, or it will not work.
if Object.const_defined?(:Engines)
  ::Engines::Plugin.class_eval do
    def default_code_paths
      %w(app/controllers app/helpers app/cells app/models components lib)
    end
  end
  ::Engines.mix_code_from :cells
end

# initialize Rails::Configuration with our own default values to spare users 
# some hassle with the installation and keep the environment cleaner (stolen from Engines :) )

Rails::Configuration.class_eval do
  def default_plugins
    if Object.const_defined?(:Engines)
      [:engines, :cells, :all]
    else
      [:cells, :all]
    end
  end

  # load application cells not defined in a plugin.
  # extend rails' default_load_paths - which eventually get it to autoloading into Dependencies.load_paths.
  def default_load_paths_with_railsroot_cells
    default_load_paths_without_railsroot_cells.concat([RAILS_ROOT+'/app/cells'])
  end

  alias_method_chain :default_load_paths, :railsroot_cells
  
end
