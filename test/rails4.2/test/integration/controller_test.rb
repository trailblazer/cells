require "test_helper"

class ControllerTest < ActionController::TestCase
  tests SongsController

  it do
    get :index
    response.body.must_equal "happy"
  end

  # HTML escaping.
  it do
    get :with_escaped
    response.body.must_equal "<h1>Yeah!</h1><b>&lt;script&gt;</b>" # only the property is escaped.
  end
end