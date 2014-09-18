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

require 'tilt'
require 'uber/inheritable_attr'
require 'uber/delegates'
require 'cell/version'

module Cell
  def self.rails_version
    Gem::Version.new(::ActionPack::VERSION::STRING)
  end

  class TemplateMissingError < RuntimeError
    def initialize(base, prefixes, view, engine, formats)
      super("Template missing: view: `#{view.to_s}.#{engine}` prefixes: #{prefixes.inspect} view_paths:#{base.inspect}")
    end
  end # Error
end

require 'cell/caching'
require 'cell/builder'
require 'cell/prefixes'
require 'cell/self_contained'
require 'cell/layout'
require 'cell/templates'
require 'cell/caching'

require 'cell/view_model'
require 'cell/concept'
# require 'cells/engines'

# TODO: only if Rails?
require 'cell/rails'
require 'cells/railtie'