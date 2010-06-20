# encoding: utf-8
require 'rubygems'
require 'test/unit'
require 'shoulda'

# wycats says...
require 'bundler'
Bundler.setup


ENV['RAILS_ENV'] = 'test'

gem_dir       = File.join(File.dirname(__FILE__), '..')
test_app_dir  = File.join(gem_dir, 'test', 'app')

# Important: Load any test ApplicationHelper before loading cells.
Dir[File.join(test_app_dir, *%w[helpers ** *.rb]).to_s].each { |f| require f }

require 'cells'

Cell::Rails.append_view_path(File.join(test_app_dir, 'cells'))
Cell::Rails.append_view_path(File.join(test_app_dir, 'cells', 'layouts'))


# Now, load the rest.
require File.join(test_app_dir, 'controllers', 'cells_test_controller')
require File.join(test_app_dir, 'controllers', 'musician_controller')

# We need to setup a fake route for the controller tests.
#ActionController::Routing::Routes.draw do |map|
#  map.connect 'cells_test/:action', :controller => 'cells_test'
#end
#ActionController::Routing::Routes.draw do |map|
#  map.connect 'musician/:action', :controller => 'musician'
#end

Dir[File.join(gem_dir, 'test', 'support', '**', '*.rb')].each { |f| require f }
require File.join(gem_dir, 'lib', 'cells', 'assertions_helper')

# Extend TestCase.
ActiveSupport::TestCase.class_eval do
  include Cells::AssertionsHelper
  include Cells::InternalAssertionsHelper
end

# Enable dynamic states so we can do Cell.class_eval { def ... } at runtime.
class Cell::Rails
  def action_method?(*); true; end
end

require File.join(test_app_dir, 'cells', 'bassist_cell')
require File.join(test_app_dir, 'cells', 'bad_guitarist_cell')