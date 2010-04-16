# encoding: utf-8

module Cells
  module Cell
    autoload :Base, 'cells/cell/base'
    autoload :View, 'cells/cell/view'
    autoload :Caching, 'cells/cell/caching'
    autoload :ActiveHelper, 'cells/cell/active_helper'
  end
end

# Mixin caching behaviour into +::Cell::Base+.
# Note: Must be done using class_eval.
Cells::Cell::Base.class_eval do
  include ::Cells::Cell::Caching
end