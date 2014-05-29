require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

require "cells"
require "sprockets/railtie" if Cell.rails_version >= "3.1"

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.cache_store = :memory_store
    config.secret_token = "some secret phrase of at least 30 characters"

    # enable asset pipeline as in development.
    if Cell.rails_version >= "3.1"
      config.assets.enabled = true
      config.assets.compile = true

      config.cells.with_assets = ["album", "song"]
    end
  end
end
