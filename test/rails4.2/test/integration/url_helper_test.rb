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

    def default_url_options
      {host: "rails.sucks"}
    end
  end

  let (:song_cell) { Cell.new(Song.new, controller: controller) }

  # path helpers work in cell instance.
  it { song_cell.songs_path.must_equal "/songs" }
  it { song_cell.().must_equal "http://rails.sucks/songs/1" }
end
