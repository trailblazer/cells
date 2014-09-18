require 'test_helper'

class ViewExtensionsTest < ActionController::TestCase
  tests MusicianController

  class Cell < Cell::Concept
    def show
      "#{model}"
    end
  end

  # #concept is available in controller views.
  test "concept in view" do
    get :view_with_concept
    @response.body.must_equal "Up For Breakfast" # TODO: test options/with twin.
  end
end