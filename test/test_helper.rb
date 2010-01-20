# encoding: utf-8
require 'rubygems'

begin
  require 'test/unit'
rescue
  gem 'test-unit', '1.2.3'
  require 'test/unit'
end

# Require app's test_helper.rb if such exists.
app_test_helper = if defined?(Rails)
  Rails.root.join('test', 'test_helper')
else
  # Assuming we are in something like APP_ROOT/vendor/plugins/cells that is.
  File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. .. test test_helper])) rescue nil
end
require app_test_helper if File.exist?(app_test_helper)

ENV['RAILS_ENV'] = 'test'

# Important: Load any ApplicationHelper before loading cells.
Dir[File.join(File.dirname(__FILE__), *%w[app helpers ** *.rb]).to_s].each { |f| require f }

require 'cells'

Dir[File.join(File.dirname(__FILE__), *%w[app controllers ** *.rb]).to_s].each { |f| require f }

# Load test support files.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

Cell::Base.add_view_path File.join(File.dirname(__FILE__), *%w[app cells])
Cell::Base.add_view_path File.join(File.dirname(__FILE__), *%w[app cells layouts])

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
end

# require 'active_support/test_case' # for some reason ActionView::TestCase is undefined even after doing this. =S
# puts defined?(ActionView::TestCase)