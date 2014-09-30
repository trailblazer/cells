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
    module Helpers
      def cell(name, *args)
        ViewModel.cell_for(name, @controller, *args)
      end
    end

    extend ActionController::TestCase::Behavior::ClassMethods
    class_attribute :_controller_class


    def invoke(state, *args)
      @last_invoke = self.class.controller_class.new(@controller).render_state(state, *args)
    end

    if Cell.rails_version >= Gem::Version.new('4.0')
      include ActiveSupport::Testing::ConstantLookup
      def self.determine_default_controller_class(name) # FIXME: fix that in Rails 4.x.
        determine_constant_from_test_name(name) do |constant|
          Class === constant #&& constant < ActionController::Metal
        end
      end
    end

  end
end
