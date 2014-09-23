require 'test_helper'

class ViewExtensionsTest < ActionController::TestCase
  tests MusicianController

  class Cell < Cell::Concept
    def show
      "<b>#{model}</b>"
    end
  end

  # #concept is available in controller views.
  test "concept(..).show" do
    get :view_with_concept_with_show
    @response.body.must_equal "&lt;b&gt;Up For Breakfast&lt;/b&gt;" # TODO: test options/with twin.
  end

  test "concept(..).call" do
    get :view_with_concept_with_call
    @response.body.must_equal "<b>A Tale That Wasn't Right</b>" # TODO: test options/with twin.
  end

  test "concept(..) without #call" do
    get :view_with_concept_without_call
    @response.body.must_equal "<b>A Tale That Wasn't Right</b>"
  end
end