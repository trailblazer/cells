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
  # +invoke+::  Renders the passed +state+ with your tested cell.
  # +assert_selector+:: Like #assert_select except that the last argument is the html markup you wanna test.
  # +cell+:: Gives you a cell instance for unit testing and stuff.
  class TestCase < ActiveSupport::TestCase
       include TestHelper
  end
end
