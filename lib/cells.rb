module Cells
  # Setup your special needs for Cells here. Use this to add new view paths.
  #
  # Example:
  #
  #   Cells.setup do |config|
  #     config.append_view_path "app/view_models"
  #   end
  #
  def self.setup
    yield(Cell::Rails)
  end
end

require 'cell'
require 'uber/inheritable_attr'
require 'cell/caching'
require 'cell/builder'

require 'cell/view_model'
# require 'cells/engines'
require 'cells/railtie'


