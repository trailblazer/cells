ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

# MiniTest::Spec.class_eval do
#   after :each do
#     # DatabaseCleaner.clean
#     Thing.delete_all
#     Comment.delete_all
#     User.delete_all
#   end
# end