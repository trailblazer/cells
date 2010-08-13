# encoding: utf-8

require 'active_support'
require 'action_controller'


require 'cell/base_methods'

require 'cell'
require 'cells/rails' # helper.
require 'cell/rails'

require 'cells/helpers'


module Cells
  # Any config should be placed here using +mattr_accessor+.

  # Default view paths for Cells.
  DEFAULT_VIEW_PATHS = [
    File.join('app', 'cells'),
    File.join('app', 'cells', 'layouts')
  ]

  class << self
    # Holds paths in which Cells should look for cell views (i.e. view template files).
    #
    # == Default:
    #
    #   * +app/cells+
    #   * +app/cells/layouts+
    #
    def self.view_paths
      ::Cell::Base.view_paths
    end
    def self.view_paths=(paths)
      ::Cell::Base.view_paths = paths
    end
  end

  # Cells setup/configuration helper for initializer.
  #
  # == Usage/Examples:
  #
  #   Cells.setup do |config|
  #     config.cell_view_paths << Rails.root.join('lib', 'cells')
  #   end
  #
  def self.setup
    yield(self)
  end
end

Cell::Base = Cell::Rails

Cell::Base.view_paths = Cells::DEFAULT_VIEW_PATHS if Cell::Base.view_paths.blank?


require "rails/railtie"
class Cells::Railtie < Rails::Railtie
  initializer "cells.attach_router" do |app|
    Cell::Rails.class_eval do
      include app.routes.url_helpers
    end
    
    Cell::Base.url_helpers = app.routes.url_helpers
  end
  
  initializer "cells.add_load_path" do |app|
    #ActiveSupport::Dependencies.load_paths << Rails.root.join(*%w[app cells])
    ### DISCUSS: how are cell classes found by Rails?
  end
end