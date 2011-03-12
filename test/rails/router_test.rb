module ApplicationTests
  class RouterTest < ActionController::TestCase
    tests MusicianController

    context "A Rails app" do
      should "allow cells to use url_helpers" do
        BassistCell.class_eval do
          def promote; render; end
        end

        #assert ::Cell::Rails.view_context_class._routes, "Cells::Railtie initializer wasn't invoked."
        #assert ! ::OmgController.new.respond_to?( :render_cell)

        get "index"
        assert_response :success
        assert_equal "Find me at <a href=\"/musician\">vd.com</a>", @response.body
      end

      should "allow cells to use *_url helpers" do
        BassistCell.class_eval do
          def promote_again; render; end
        end

        #assert ::Cell::Rails.view_context_class._routes, "Cells::Railtie initializer wasn't invoked."
        #assert ! ::OmgController.new.respond_to?( :render_cell)

        get "promote"
        assert_response :success
        assert_equal "Find me at <a href=\"http://test.host/\">vd.com</a>", @response.body
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
