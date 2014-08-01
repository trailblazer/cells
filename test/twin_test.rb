require 'test_helper'
require 'cell/twin'

if Cell.rails_version >= 3.1

class TwinTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    class Twin < Cell::Twin
      property :title
      option :online?
    end

    include Cell::Twin::Properties
    properties Twin

    def show
      "#{title} is #{online?}"
    end

    def title
      super.downcase
    end
  end

  let (:model) { OpenStruct.new(:title => "Kenny") }

  it { SongCell.new(nil, model, :online? => true).call.must_equal "kenny is true" }
end

end