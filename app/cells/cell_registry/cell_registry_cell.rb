class CellRegistryCell < Cell::Base
  
  def list_registry
    @registered = Cell::Registry.registered
    @registry   = Cell::Registry.cells
    
    return
  end
  
  def reload_all
    Cell::Registry.registered.each{|cell_name| Cell::Registry.reload(cell_name)}
  end
  
end
