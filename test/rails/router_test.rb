require 'test_helper'

module ApplicationTests
  class RouterTest < ActionController::TestCase
    tests MusicianController

    context "A Rails app" do
      should "pass url_helpers to the cell instance" do
        assert_equal "/", BassistCell.new(@controller).root_path
      end
      
      should "allow cells to use url_helpers" do
        BassistCell.class_eval do
          def promote; render; end
        end

        get "index"
        assert_response :success
        assert_equal "Find me at <a href=\"/musician\">vd.com</a>", @response.body
      end

      should "allow cells to use *_url helpers when mixing in AC::UrlFor" do
        get "promote"
        assert_response :success
        assert_equal "Find me at <a href=\"http://test.host/\">vd.com</a>\n", @response.body
      end

      should "allow cells to use #config" do
        BassistCell.class_eval do
          def provoke; render; end
        end

        get "promotion"
        assert_response :success
        assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", @response.body
      end
    end
  end
end
