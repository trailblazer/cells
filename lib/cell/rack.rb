require 'cell/base'

module Cell
  # Use Cell::Rack to mount your cell to a rack-route with a working +session+ and +params+ reference
  # in the cell. This is especially useful when using gems like devise with your cell, without the
  # entire Cell::Rails overhead.
  #
  # The only dependency these kinds of cells have is a rack-compatible request object.
  #
  # Example:
  #
  #   match "/dashboard/comments" => proc { |env|
  #     request = ActionDispatch::Request.new(env)
  #     [ 200, {}, [ Cell::Rack.render_cell_for(:comments, :show, request) ]]
  #   }
  class Rack < Base
    attr_reader :request
    delegate :session, :params, :to => :request
    
    class << self
      # DISCUSS: i don't like these class methods. maybe a RenderingStrategy?
      def create_cell(request, *args) # defined in Builder.
        new(request)
      end
      
      def render_cell_state(cell, state, request, *args) # defined in Rendering.
        super(cell, state, *args)
      end
    end
    
    def initialize(request)
      super()
      @request = request
    end
  end
end
