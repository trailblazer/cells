require 'test_helper'

class MusiciansController < ApplicationController
end

class UrlHelperTest < MiniTest::Spec
  include Cell::Testing
  controller MusiciansController

  class Cell < Cell::ViewModel
    def show
      url_for(model)
    end
  end

  let (:song_cell) { Cell.new(Song.new, controller: controller) }

  # path helpers work in cell instance.
  it { song_cell.songs_path.must_equal "/songs" }
  it { song_cell.().must_equal "http://test.host/songs/1" }
end


class UrlTest < ActionDispatch::IntegrationTest
  include ::Capybara::DSL

  it do
    visit "/songs/new" # cell.url_for(Song.new)
    page.text.must_equal "http://www.example.com/songs/1"
  end

  # it do
  #   visit "/songs/1/edit"
  #   page.text.must_equal "http://www.example.com/songs/1"
  # end


end

class AssetsHelperTest < ActionController::TestCase
  tests SongsController

  it do
    get :with_image_tag
    response.body.must_equal "<img src=\"/images/logo.png\" alt=\"Logo\" />"
  end
end