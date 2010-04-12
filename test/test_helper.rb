# encoding: utf-8
require 'rubygems'

begin
  require 'test/unit'
rescue
  gem 'test-unit', '1.2.3'
  require 'test/unit'
end

begin
  require 'active_support'
rescue
  gem 'activesupport'
  require 'active_support'
end

begin
  require 'action_controller'
rescue
  gem 'actionpack'
  require 'action_controller'
end

begin
  require 'action_view'
rescue
  gem 'actionpack'
  require 'action_view'
end

begin
  require 'shoulda'
rescue
  gem 'shoulda'
  require 'shoulda'
end

require 'active_support/test_case'

# Require app's test_helper.rb if such exists.
app_test_helper = if defined?(Rails)
  Rails.root.join('test', 'test_helper')
else
  # Assuming we are in something like APP_ROOT/vendor/plugins/cells that is.
  File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. .. test test_helper])) rescue nil
end
require app_test_helper if File.exist?(app_test_helper)

ENV['RAILS_ENV'] = 'test'
test_app_path = File.expand_path(File.join(File.dirname(__FILE__), 'app').to_s)

# Important: Load any ApplicationHelper before loading cells.
Dir[File.join(test_app_path, *%w[helpers ** *.rb]).to_s].each { |f| require f }

require 'cells'

Cell::Base.add_view_path File.join(test_app_path, 'cells')
Cell::Base.add_view_path File.join(test_app_path, 'cells', 'layouts')

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

require File.join(File.dirname(__FILE__), *%w[app cells bassist_cell])