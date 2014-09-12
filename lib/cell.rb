module Cell
  require 'uber/version'
  def self.rails_version
    Uber::Version.new(::ActionPack::VERSION::STRING)
  end

  class TemplateMissingError < RuntimeError
    def initialize(base, prefixes, view, engines, formats)
      super("Template missing: view: `#{view.to_s}[.#{engines.join('|.')}]` prefixes: #{prefixes.inspect} view_paths:#{base.inspect}")
    end
  end
end