# encoding: utf-8

begin
  require 'active_support'
rescue
  gem 'activesupport'
  require 'active_support'
end

begin
  require 'action_controller'
rescue
  gem 'actionpack'
  require 'action_controller'
end

begin
  require 'action_view'
rescue
  gem 'actionpack'
  require 'action_view'
end

# A bit of cheating to avoid breaking the current pattern: Cell::Base, etc.
require 'cell'

# Tell *Rails* to load files in path:
#
#   * +app/cells+
#
ActiveSupport::Dependencies.load_paths << Rails.root.join(*%w[app cells]) if defined?(Rails)

# Tell *Cells* to look for view templates in paths:
#
#   * +app/cells+
#   * +app/cells/layouts+
#
Cell::Base.add_view_path File.join(*%w[app cells])
Cell::Base.add_view_path File.join(*%w[app cells layouts]) ### DISCUSS: do we need shared layouts for different cells?

module Cells
  autoload :Helper, 'cells/helper'
end

require 'cells/rails'