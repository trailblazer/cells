#require '/home/nick/projects/rails/railties/lib/rails/test/isolation/abstract_unit'
require 'abstract_unit'

module ApplicationTests
  class RouterTest < ActionController::TestCase#Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation
    
    
    def app
      #@app ||= begin
        Rails.application
      #end
    end

    context "A Rails app" do
      setup do
        build_app
        FileUtils.rm_rf("#{app_path}/config/environments")  # otherwise we get a undefined method `action_mailer' for #<Rails::Application::Configuration
        
        require "#{app_path}/config/environment"  # DISCUSS: introduce #initialize_rails?
        boot_rails
        
        app_file "config/routes.rb", <<-RUBY
          AppTemplate::Application.routes.draw do |map|
            match '/cell', :to => 'omg#index'
          end
        RUBY
        
        
        require 'rack/test'
        extend Rack::Test::Methods  # needs @routes.
      end
      
      should "allow cells to use url_helpers" do
        controller "omg", <<-RUBY
          class OmgController < ActionController::Base
            def index
              render :text => render_cell(:bassist, :promote)
            end
          end
        RUBY
        
        BassistCell.class_eval do
          def promote; render; end
        end
      
        #assert ::Cell::Rails.view_context_class._routes, "Cells::Railtie initializer wasn't invoked."
        #assert ! ::OmgController.new.respond_to?( :render_cell)
        
        get "/cell"
        assert_response :success
        assert_equal "Find me at <a href=\"/cell\">vd.com</a>", last_response.body
      end
      
      should "allow cells to use #config" do
        controller "omg", <<-RUBY
          class OmgController < ActionController::Base
            def index
              render :text => render_cell(:bassist, :provoke)
            end
          end
        RUBY
        
        BassistCell.class_eval do
          def provoke; render; end
        end
        
        get "/cell"
        assert_response :success
        assert_equal "That's me, naked <img alt=\"Me\" src=\"/images/me.png\" />", last_response.body
      end 
    end
  end
end