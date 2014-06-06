require 'rails/railtie'

module Cells
  module Engines
    module VersionStrategy
      def registered_engines
        ::Rails::Engine::Railties.engines
      end

      def existent_directories_for(path)
        path.existent_directories
      end
    end
  end
end