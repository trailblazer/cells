require "test_helper"
require "cell/partial"

class PartialTest < Minitest::Spec
  class WithPartial < Cell::ViewModel
    self.view_paths = ['test/fixtures'] # doesn't exist.
    include ::Cell::Erb

    include Partial

    def show
      render partial: "../fixtures/partials/show.html"
    end

    def show_with_format
      render partial: "../fixtures/partials/show", formats: [:xml]
    end

    def show_without_partial
      render :show
    end
  end

  class WithPartialAndManyViewPaths < WithPartial
    self.view_paths << ['app/views']
  end

  it { assert_equal "I Am Wrong And I Am Right", WithPartial.new(nil).show }
  it { assert_equal "<xml>I Am Wrong And I Am Right</xml>", WithPartial.new(nil).show_with_format }
  it { assert_equal "Adenosine Breakdown", WithPartial.new(nil).show_without_partial }

  it { assert_equal "I Am Wrong And I Am Right", WithPartialAndManyViewPaths.new(nil).show }
  it { assert_equal "<xml>I Am Wrong And I Am Right</xml>", WithPartialAndManyViewPaths.new(nil).show_with_format }
  it { assert_equal "Adenosine Breakdown", WithPartialAndManyViewPaths.new(nil).show_without_partial }
end
