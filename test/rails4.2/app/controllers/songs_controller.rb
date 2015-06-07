class SongsController < ApplicationController
  def show
    # renders show.html.haml
  end

  def index
    render text: cell(:song).()
  end

  def new
    render text: cell(:song).url_for(Song.new)
  end

  def edit
    render text: cell(:song).video_path(1)
  end

  def with_image_tag
    render text: cell(:song).image_tag("logo.png")
  end

  def with_escaped
    render layout: false
  end
end