require 'tilt'
require 'uber/inheritable_attr'
require 'uber/delegates'
require 'cell/version'

module Cell
  def self.rails_version
    Gem::Specification.find_by_name('actionpack').version
  end

  class TemplateMissingError < RuntimeError
    def initialize(base, prefixes, view, engine, formats)
      super("Template missing: view: `#{view.to_s}.#{engine}` prefixes: #{prefixes.inspect} view_paths:#{base.inspect}")
    end
  end # Error
end

require 'cell/caching'
require 'cell/caching/notification'
require 'cell/builder'
require 'cell/prefixes'
require 'cell/self_contained'
require 'cell/layout'
require 'cell/templates'
require 'cell/caching'
require 'cell/erb'

require 'cell/view_model'
require 'cell/concept'
# require 'cells/engines'

# TODO: only if Rails?
require 'cell/rails'
require 'cells/railtie'
