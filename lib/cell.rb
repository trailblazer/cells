# encoding: utf-8

module Cell
  autoload :Base, 'cell/base'
  autoload :View, 'cell/view'
  autoload :Caching, 'cell/caching'
  autoload :ActiveHelper, 'cell/active_helper'
end

# Mixin caching behaviour into +::Cell::Base+.
# Note: Must be done using class_eval.
Cell::Base.class_eval do
  include ::Cell::Caching
end