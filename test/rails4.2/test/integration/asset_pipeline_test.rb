require "test_helper"
require "capybara/rails"
require "capybara/dsl"

# This blog post helped so much: http://rakeroutes.com/blog/write-a-gem-for-the-rails-asset-pipeline/
# Thanks, Stephen!!! :)

class AssetPipelineTest < ActionDispatch::IntegrationTest
  include ::Capybara::DSL
  # register_spec_type(/integration$/, self)

  it "what" do
    visit "/assets/application.css"
    page.text.must_include 'var Album = {};'
    page.text.must_include 'var Songs = [];'
  end
end
