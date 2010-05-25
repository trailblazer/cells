require File.join(File.dirname(__FILE__), '/../test_helper')
require 'rack/test'
require 'cells/sinatra'

class CellsApp < Sinatra::Base
  helpers Cells::Sinatra
  
  get "/" do
    render_cell :singer, :sing
  end
end


class SinatraIntegrationTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  
  def app
    CellsApp
  end
  
  context "A Sinatra app" do
    should "render the singer cell" do
      assert_equal "Laaa", get("/").body
    end
  end
end