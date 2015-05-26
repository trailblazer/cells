require 'test_helper'

class MusiciansController < ApplicationController
end

class UrlHelperTest < MiniTest::Spec
  controller MusiciansController

  let (:song_cell) { SongCell.new(controller) }

  class SongCell < Cell::ViewModel
  end

  # URL helpers work in cell instance.
  it { song_cell.songs_path.must_equal "/songs" }
end
