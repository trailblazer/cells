require 'generators/cells/base'

module Erb
  module Generators
    class CellGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_views
        for state in actions do
          @state = state
          @path = File.join(base_path, "#{state}.html.erb")  #base_path defined in Cells::Generators::Base.
          template "view.erb", @path
        end
      end
    end
  end
end
