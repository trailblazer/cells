module Trailblazer
  module Generators
    class ViewGenerator < Cell # Trailblazer::Generators::Cell
      def create_views
        for state in actions do
          @state  = state
          @path   = File.join(base_path, "views/#{state}.#{handler}")  #base_path defined in Cells::Generators::Base.
          template "view.#{handler}", @path
        end
      end

    private
      def handler
        raise "Please implement #handler in your view generator and return something like `:erb`."
      end
    end
  end
end
