require "tilt"
require "uber/inheritable_attr"
require "uber/delegates"
require "cell/version"

module Cell
  autoload :TestCase, "cell/test_case"
  autoload :Testing,  "cell/testing"

  def self.rails_version
    Gem::Version.new(ActionPack::VERSION::STRING)
  end

  class TemplateMissingError < RuntimeError
    def initialize(prefixes, view)
      super("Template missing: view: `#{view.to_s}` prefixes: #{prefixes.inspect}")
    end
  end # Error
end

require "cell/caching"
require "cell/caching/notification"
require "uber/builder"
require "cell/prefixes"
require "cell/self_contained"
require "cell/layout"
require "cell/templates"
require "cell/abstract"
require "cell/util"
require "cell/view_model"
require "cell/concept"
require "cell/escaped"


require "cell/railtie" if defined?(Rails)
