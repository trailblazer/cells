require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

require "cells"
require 'sprockets/railtie'

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.i18n.enforce_available_locales = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.cache_store = :memory_store
    config.secret_token = SecureRandom.uuid

    # enable asset pipeline as in development.
    config.assets.enabled = true
    config.assets.compile = true
    config.cells.with_assets = ["album", "song"]
    config.app_generators.template_engine :haml
    config.cache_classes = true

    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Raise exceptions instead of rendering exception templates
    config.action_dispatch.show_exceptions = false

    # Disable request forgery protection in test environment
    config.action_controller.allow_forgery_protection    = false
    config.active_support.deprecation = :stderr
  end
end
