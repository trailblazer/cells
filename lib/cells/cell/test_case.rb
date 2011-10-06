require "active_support/test_case"
module Cell
  # Test your cells.
  #
  # This class is roughly equal to ActionController::TestCase, exposing the same semantics. It will try 
  # to infer the tested cell name from the test name if you use declarative testing. You can also set it
  # with TestCase.tests.
  #
  # A declarative test would look like
  #
  #   class SellOutTest < Cell::TestCase
  #     tests ShoppingCartCell
  #
  #     it "should be rendered nicely" do
  #       invoke :order_button, :items => @fixture_items
  #       
  #       assert_select "button", "Order now!"
  #     end
  #
  # You can also do stuff yourself, like
  #
  #     it "should be rendered even nicer" do
  #       html = render_cell(:shopping_cart, :order_button, , :items => @fixture_items)
  #       assert_selector "button", "Order now!", html
  #     end
  #
  # Or even unit test your cell:
  #
  #     it "should provide #default_items" do
  #       assert_equal [@item1, @item2], cell(:shopping_cart).default_items
  #     end
  #
  # == Test helpers
  #
  # Basically, we got these new methods:
  #
  # +invoke+::  Renders the passed +state+ with your tested cell. You may pass options like in #render_cell.
  # +render_cell+:: As in your views. Will return the rendered view.
  # +assert_selector+:: Like #assert_select except that the last argument is the html markup you wanna test.     
  # +cell+:: Gives you a cell instance for unit testing and stuff. 
  class TestCase < ActiveSupport::TestCase
    module AssertSelect
      # Invokes assert_select for the last argument, the +content+ string.
      #
      # Example:
      #   assert_selector "h1", "The latest and greatest!", "<h1>The latest and greatest!</h1>"
      #
      # would be true.
      def assert_selector(*args, &block)
        rails_assert_select(HTML::Document.new(args.pop).root, *args, &block)
      end
      
      # Invokes assert_select on the markup set by the last #invoke.
      #
      # Example:
      #   invoke :latest
      #   assert_select "h1", "The latest and greatest!"
      def assert_select(*args, &block)
        super(HTML::Document.new(last_invoke).root, *args, &block)
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
        @controller.send(:initialize_current_url)
      end
      
      # Use this for functional tests of your application cells.
      #
      # Example:
      #   should "spit out a h1 title" do
      #     html = render_cell(:news, :latest)
      #     assert_selekt html, "h1", "The latest and greatest!"
      def render_cell(name, state, *args)
        @subject_cell = ::Cell::Base.create_cell_for(@controller, name, *args)
        @view_assigns = extract_state_ivars_for(@subject_cell) do
          @last_invoke = @subject_cell.render_state(state, *args)
        end
        
        @last_invoke
      end

      # Runs the block while computing the instance variables diff from before and after. 
      def extract_state_ivars_for(cell)
        before  = cell.instance_variables
        before += [:@cell, :@state_name]
        yield 
        after   = cell.instance_variables
        
        Hash[(after - before).collect do |var|
          next if var =~ /^@_/
          [var[1, var.length].to_sym, cell.instance_variable_get(var)]
        end]
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
    include ActionController::Assertions::SelectorAssertions  # imports "their" #assert_select.
    alias_method :rails_assert_select, :assert_select # i hate that.
    include AssertSelect
    
    
    attr_reader :last_invoke, :subject_cell, :view_assigns
    
    def invoke(state, *args)
      @last_invoke = self.class.controller_class.new(@controller, *args).render_state(state)
    end
    
    
    class << self
      # Sets the controller class name. Useful if the name can't be inferred from test class.
      # Expects +controller_class+ as a constant. Example: <tt>tests WidgetController</tt>.
      def tests(controller_class)
        self.controller_class = controller_class
      end

      def controller_class=(new_class)
        write_inheritable_attribute(:controller_class, new_class)
      end

      def controller_class
        if current_controller_class = read_inheritable_attribute(:controller_class)
          current_controller_class
        else
          self.controller_class = determine_default_controller_class(name)
        end
      end

      def determine_default_controller_class(name)
        name.sub(/Test$/, '').constantize
      rescue NameError
        nil
      end
    end

  end
end
