require 'cells'

# Make cell class interface leaner, i.e. ::Cell::Base < ::Cells::Cell::Base, etc.
# Note: Reason for doing like so is to make load path-resolving complexity to a minimum.
#
module Cell
  Base = ::Class.new(::Cells::Cell::Base)
  View = ::Class.new(::Cells::Cell::View)
end