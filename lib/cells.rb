# = Cells
#
# Cells are view components for Rails. Being lightweight controllers with actions and views, cells are the
# answer to <tt>DoubleRenderError</tt>s and the long awaited ability to render actions within actions.
# 
# == Directory structure
#
# Cells live in +app/cells/+ and have a similar file layout as controllers.
#
#   app/
#     cells/
#       shopping_cart_cell.rb
#       shopping_cart/
#         status.html.erb
#         product_list.haml
#       layouts/
#         box.html.erb
#
# == Cell nesting
# 
# Is is good practice to split up complex cell views into multiple states or views. Remember, you can always use
# <tt>render :view => ...</tt> and <tt>render :state => ...</tt> in your views.
#
# Following this, you stick to encapsulation and save your code from getting inscrutable, as it happens in most
# controller views, partials, and so called "helpers".
#
# Given the following setup:
#
#   class ShoppingCartCell < Cell::Base
#     def cart
#       @items = items_in_cart
#       render
#     end
#
#     def order_button
#       render
#     end
#
# You could now render the "Order!" button in the +cart.haml+ view.
#
#   - for item in @items
#     = @item.title
#
#   render :state => :order_button
# 
# which is more than just a partial, as you may execute additional code in the state method.
#
# == View inheritance
#
# Unlike controllers, Cells can form a class hierarchy. Even Views are inherited, which is pretty useful
# when overriding only small parts of the view.
#
# So if you'd need a special "Order!" button with sparkling stars on christmas, your cell would go like this.
#
#   class XmasCartCell < ShoppingCartCell
#   end
#
# Beside your new class you'd provide a star-sprangled button view in +xmas_cart/order_button.haml+.
# When rendering the +cart+ state, the states as well as the "missing" views are inherited from ancesting cells,
# this is pretty DRY and object-oriented, isn't it?
require 'action_controller'

require 'cell'
require 'cells/rails'
require 'cell/rails'
require 'cell/test_case' if Object.const_defined?("Rails") and Rails.env == "test"

module Cells
  # Default view paths for Cells.
  DEFAULT_VIEW_PATHS = [
    File.join('app', 'cells'),
    File.join('app', 'cells', 'layouts')
  ]

  # Setup your special needs for Cells here. Use this to add new view paths.
  #
  # Example:
  #
  #   Cells.setup do |config|
  #     config.append_view_path << "app/view_models"
  #   end
  #
  def self.setup
    yield(Cell::Base)
  end
  
  def self.config(&block)
    instance_exec(&block)
  end

  def self.method_missing(sym, *args, &block)
    typename = "#{sym}_cell".classify
    type_definition = "class ::#{typename} < Cells::Custom; end"
    eval type_definition
    "::#{typename}".constantize.b = block
  end
  class Custom
    def self.b=(x)
      @b = x
    end
    def self.builders
      [@b]
    end
  end
  
end

Cell::Base = Cell::Rails

Cell::Base.view_paths = Cells::DEFAULT_VIEW_PATHS if Cell::Base.view_paths.blank?


require "rails/railtie"

class Cells::Railtie < Rails::Railtie
  initializer "cells.attach_router" do |app|
    Cell::Rails.class_eval do
      include app.routes.url_helpers
    end
    
    Cell::Base.url_helpers = app.routes.url_helpers
  end
  
  rake_tasks do
    load "cells/cells.rake"
  end
end
