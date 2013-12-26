# This file contains VersionStrategies for the Cell and Cells module for Rails >= 3.1.
module Cell
  Layouts = ActionView::Layouts

  # Methods to be included in Cell::Rails in 3.1 context.
  module VersionStrategy
    extend ActiveSupport::Concern

    include AbstractController::UrlFor  # must be included before _routes is set in Railstie. # TODO: remove that.


    module ClassMethods
      def helper_modules
        [_routes.url_helpers, _routes.mounted_helpers, _helpers]
      end
    end

  private
    def process_opts_for(opts, state)
      opts[:action] = opts[:view] || state

      lookup_context.formats = [opts.delete(:format)] if opts[:format]
    end
  end
end


module Cells
  module Engines
    module VersionStrategy
      def registered_engines
        ::Rails::Engine::Railties.new
      end

      def existent_directories_for(path)
        path.existent_directories
      end
    end
  end
end
