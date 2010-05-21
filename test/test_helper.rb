# encoding: utf-8
require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_support/test_case'


ENV['RAILS_ENV'] = 'test'
test_app_path = File.expand_path(File.join(File.dirname(__FILE__), 'app').to_s)

# Important: Load any test ApplicationHelper before loading cells.
Dir[File.join(test_app_path, *%w[helpers ** *.rb]).to_s].each { |f| require f }

require 'cells'

class TestConfiguration
  cattr_accessor :basedir, :rails_view_paths, :sinatra_view_paths
  
  class << self
    # Setup the testing environment for Rails.
    def rails!
      Cell::Base.framework = :rails
      Cell::Base.view_paths = rails_view_paths
    end
    
    def sinatra!
      Cell::Base.view_paths = sinatra_view_paths
      Cell::Base.framework = :sinatra
    end
  end
end

TestConfiguration.rails_view_paths = [File.join(test_app_path, 'cells'), File.join(test_app_path, 'cells', 'layouts')]
TestConfiguration.sinatra_view_paths = [File.join(test_app_path, 'cells')]

#Cell::Base.add_view_path File.join(test_app_path, 'cells')
#Cell::Base.add_view_path File.join(test_app_path, 'cells', 'layouts')
TestConfiguration.rails!


# Now, load the rest.
Dir[File.join(test_app_path, *%w[controllers ** *.rb]).to_s].each { |f| require f }

# We need to setup a fake route for the controller tests.
ActionController::Routing::Routes.draw do |map|
  map.connect 'cells_test/:action', :controller => 'cells_test'
end

# Load test support files.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }
require File.join(File.dirname(__FILE__), *%w[.. lib cells assertions_helper])

ActiveSupport::TestCase.class_eval do
  include Cells::AssertionsHelper
  include Cells::InternalAssertionsHelper
end

require File.join(File.dirname(__FILE__), %w(app cells bassist_cell))
require File.join(File.dirname(__FILE__), %w(app cells bad_guitarist_cell))