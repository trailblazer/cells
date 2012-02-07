require 'test_helper'

module ApplicationTests
  class RouterTest < ActionController::TestCase
    tests MusicianController

    context "A Rails app" do
      should "pass url_helpers to the cell instance" do
        assert_equal "/musicians", BassistCell.new(@controller).musicians_path
      end
      
      should "allow cells to use url_helpers" do
        BassistCell.class_eval do
          def promote; render; end
        end

        get "index"
        assert_response :success
        assert_equal "Find me at <a href=\"/musicians\">vd.com</a>\n", @response.body
      end
      
      should "delegate #url_options to the parent_controller" do
        @controller.instance_eval do
          def default_url_options
            {:host => "cells.rails.org"}
          end
          
        end
        
        assert_equal "http://cells.rails.org/musicians", BassistCell.new(@controller).musicians_url
      end

      should "allow cells to use *_url helpers when mixing in AC::UrlFor" do
        get "promote"
        assert_response :success
        assert_equal "Find me at <a href=\"http://test.host/musicians\">vd.com</a>\n", @response.body
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
