#--
### DISCUSS: move this to cell_extensions.
#--
module Cell
  def self.engines_available?
    Object.const_defined?(:Engines)
  end
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
end
