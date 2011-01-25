require 'generators/cells/base'

module Cells
  module Generators
    class CellGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def say_deprecated
        say "====> This generator is now DEPRECATED. <====", :red
        say "Please use:"
        say "  rails g cell #{class_name} #{actions.join(' ')}"
      end
    end
  end
end
