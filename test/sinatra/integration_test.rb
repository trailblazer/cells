require File.join(File.dirname(__FILE__), '/../test_helper')
require 'rack/test'
require 'cells/sinatra'

class CellsApp < Sinatra::Base
  helpers Cells::Sinatra
  
  get "/" do
    render_cell :bassist, :play
  end
end


class SinatraIntegrationTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  
  def app
    CellsApp
  end
  
  context "A Sinatra app" do
    setup do
      Cell::Base.framework = :sinatra
    end
    
    should "render the bassist cell" do
      assert_equal "Doo", get("/").body
    end
    
    teardown do
      Cell::Base.framework = :rails
    end
  end
end