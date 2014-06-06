module Cell
  Layouts = AbstractController::Layouts

  # Methods to be included in Cell::Rails in 3.1-4.0 context.
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


require_relative 'engines'