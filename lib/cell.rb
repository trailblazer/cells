module Cell
  require 'uber/version'
  def self.rails_version
    Uber::Version.new(::ActionPack::VERSION::STRING)
  end
end