# encoding: utf-8
require 'action_controller/test_case'

module Cells
  module AssertionsHelper
    # Sets up a mock controller for usage in render_cell.
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
    
    # Invokes assert_select for the passed <tt>content</tt> string.
    #
    # Example:
    #   html = "<h1>The latest and greatest!</h1>"
    #   assert_selekt html, "h1", "The latest and greatest!"
    #
    # would be true.
    def assert_selekt(content, *args)
      assert_select(HTML::Document.new(content).root, *args)
    end
  end
end

