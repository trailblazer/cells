require "rails/railtie"

module Cells
  class Railtie < Rails::Railtie
    options = {}
    options[:after] = :set_routes_reloader if Cells.rails3_1?
    
    initializer "cells.attach_router", options  do |app|
      Cell::Rails.class_eval do
        include app.routes.url_helpers
      end
    end
    
    initializer "cells.setup_view_paths" do |app|
      Cell::Base.setup_view_paths!
    end
    
    rake_tasks do
      load "cells/cells.rake"
    end
  end
end
