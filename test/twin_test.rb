# require 'test_helper'
# require 'cell/twin'

# class TwinTest < Minitest::Spec
#   class SongCell < Cell::ViewModel
#     class Twin < Disposable::Twin
#       property :title
#       option :online?
#     end

#     include Cell::Twin
#     twin Twin

#     def show
#       "#{title} is #{online?}"
#     end

#     def title
#       super.downcase
#     end
#   end

#   let (:model) { OpenStruct.new(title: "Kenny") }

#   it { assert_equal("kenny is true", SongCell.new( model, :online? => true)) }
# end
