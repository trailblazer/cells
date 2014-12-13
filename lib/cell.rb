require 'tilt'
require 'uber/inheritable_attr'
require 'uber/delegates'
require 'cell/version'
require 'active_support/dependencies/autoload'

module Cell
  extend ActiveSupport::Autoload

  autoload :Concept
  autoload :TestCase
  autoload :TestHelper

  def self.rails_version
    Gem::Version.new(ActionPack::VERSION::STRING)
  end

  class TemplateMissingError < RuntimeError
    def initialize(base, prefixes, view, engine, formats)
      super("Template missing: view: `#{view.to_s}.#{engine}` prefixes: #{prefixes.inspect} view_paths:#{base.inspect}")
    end
  end # Error
end

require 'cell/caching'
require 'cell/caching/notification'
require 'uber/builder'
require 'cell/prefixes'
require 'cell/self_contained'
require 'cell/layout'
require 'cell/templates'
require 'cell/view_model'

require 'cell/railtie'
