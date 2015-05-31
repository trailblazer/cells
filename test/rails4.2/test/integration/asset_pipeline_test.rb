require "test_helper"
require "capybara/rails"
require "capybara/dsl"

# This blog post helped so much: http://rakeroutes.com/blog/write-a-gem-for-the-rails-asset-pipeline/
# Thanks, Stephen!!! :)

class AssetPipelineTest < ActionDispatch::IntegrationTest
  include ::Capybara::DSL

  it do
    visit "/assets/application.css"

    # both engine User::Cell and SongCell provide assets.
    page.text.must_equal "user{background:green}.song{background:red}"
  end
end
