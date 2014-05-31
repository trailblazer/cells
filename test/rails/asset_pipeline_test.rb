require "test_helper"
require "capybara/rails"

# This blog post helped so much: http://rakeroutes.com/blog/write-a-gem-for-the-rails-asset-pipeline/
# Thanks, Stephen!!! :)

if Cell.rails_version >= 3.1

  class AssetPipelineTest < MiniTest::Spec
    include Capybara::DSL
    register_spec_type(/integration$/, self)

    it "what" do
      visit "/assets/application.js"
      page.text.must_include 'var Album = {};'
      page.text.must_include 'var Songs = [];'
    end
  end

end