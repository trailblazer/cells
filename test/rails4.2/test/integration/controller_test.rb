require "test_helper"

class ControllerTest < ActionController::TestCase
  tests SongsController

  # TODO: test url stuff in Song#show.
  it do
    get :index
    response.body.must_equal "happy"
  end

end