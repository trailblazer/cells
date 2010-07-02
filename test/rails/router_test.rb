#require 'rails'
#require 'railties'
#require '/home/nick/.rvm/gems/ruby-1.9.1-p378/bundler/gems/rails-07b08721a226ff01f983e61d99ab4da96e296c97-master/railties/test/abstract_unit'
require '/home/nick/.rvm/gems/ruby-1.9.1-p378/bundler/gems/rails-07b08721a226ff01f983e61d99ab4da96e296c97-master/railties/test/isolation/abstract_unit'

module ApplicationTests
  class RouterTest < Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation

    def app
      Rails.application
    end

    context "A Rails app" do
   # How does MyApp know about cells?
   # How to tell it to run cells/init?   
      should "allow cells to use url_helpers" do
      
      puts "setuuuuuuuuuuuuuuuuuuup"
        boot_rails
        require "rails"
        require "action_controller/railtie"
        
        require 'cells'
      
      
        BassistCell.class_eval do
          def promote; render; end
        end
        
        class MyApp < Rails::Application
          config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
          config.session_store :cookie_store, :key => "_myapp_session"
        end
  
        MyApp.initialize!
  
        class ::ApplicationController < ActionController::Base
        end
  
        class ::OmgController < ::ApplicationController
          def index
            render :text => render_cell(:bassist, :promote)
          end
        end
  
        MyApp.routes.draw do
          match "/" => "omg#index", :as => :omg
        end
  
        
        #assert ! ::OmgController.new.respond_to?( :render_cell) 
  
  
        require 'rack/test'
        extend Rack::Test::Methods
  
        get "/"
        #assert_equal last_response.status, :ok
        assert_equal "Find me at <a href=\"cells_test/index\">vd.com</a>", last_response.body
      end
      
    
    end
  end
end
