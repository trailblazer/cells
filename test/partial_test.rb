require "test_helper"
require "cell/partial"

class PartialTest < MiniTest::Spec
  class WithPartial < Cell::ViewModel
    self.view_paths = ['test/fixtures'] # doesn't exist.
    self.template_engine = :erb

    include Partial

    def show
      render partial: "../fixtures/partials/show.html"
    end
  end

  it { WithPartial.new(nil).show.must_equal "I Am Wrong And I Am Right" }
end