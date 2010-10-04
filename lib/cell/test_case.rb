module Cell
  class TestCase < ActiveSupport::TestCase
    module AssertSelect
      # Invokes assert_select for the last argument, the +content+ string.
      #
      # Example:
      #   assert_select "h1", "The latest and greatest!", "<h1>The latest and greatest!</h1>"
      #
      # would be true.
      def assert_select(*args)
        content = args.pop
        super(HTML::Document.new(content).root, *args)
      end
    end
    
    module TestMethods
      def setup
        @controller = Class.new(ActionController::Base).new
        @request    = ::ActionController::TestRequest.new
        @response   = ::ActionController::TestResponse.new
        @controller.request = @request
        @controller.response = @response
        @controller.params = {}
      end
      
      # Use this for functional tests of your application cells.
      #
      # Example:
      #   should "spit out a h1 title" do
      #     html = render_cell(:news, :latest)
      #     assert_selekt html, "h1", "The latest and greatest!"
      def render_cell(*args)
        @controller.render_cell(*args)
      end
      
      # Builds an instance of <tt>name</tt>Cell for unit testing.
      # Passes the optional block to <tt>cell.instance_eval</tt>.
      #
      # Example:
      #   assert_equal "Banks kill planet!" cell(:news, :topic => :terror).latest_headline
      def cell(name, opts={}, &block)
        cell = ::Cell::Base.create_cell_for(@controller, name, opts)
        cell.instance_eval &block if block_given?
        cell
      end
    end
    
    include TestMethods
    include ActionDispatch::Assertions::SelectorAssertions
    include AssertSelect
  end
end
