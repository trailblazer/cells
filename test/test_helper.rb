# encoding: utf-8
require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'minitest/spec'

ENV['RAILS_ENV'] = 'test'

require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.

gem_dir       = File.join(File.dirname(__FILE__), '..')
test_app_dir  = File.join(gem_dir, 'test', 'app')

require 'cells'

Cell::Rails.append_view_path(File.join(test_app_dir, 'cells'))

require "cell/test_case"
# Extend TestCase.
ActiveSupport::TestCase.class_eval do
  def assert_not(assertion)
    assert !assertion
  end
  
  def assert_is_a(klass, object)
    assert object.is_a?(klass)
  end
end

# Enable dynamic states so we can do Cell.class_eval { def ... } at runtime.
class Cell::Rails
  def action_method?(*); true; end
end

require File.join(test_app_dir, 'cells', 'bassist_cell')
require File.join(test_app_dir, 'cells', 'trumpeter_cell')
require File.join(test_app_dir, 'cells', 'bad_guitarist_cell')

require "haml"
require "haml/template" # Thanks, Nathan!
