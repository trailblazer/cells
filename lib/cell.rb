
module Cell
  autoload :Base, 'cell/base'
  autoload :Caching, 'cell/caching'
  autoload :View, 'cell/view'
end

# Mixin caching behaviour into +Cell::Base+.
# Note: Must be done using class_eval.
Cell::Base.class_eval do
  include ::Cell::Caching
end