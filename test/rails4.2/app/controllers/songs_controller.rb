class SongsController < ApplicationController
  def show
    # renders show.html.haml
  end

  def index
    render text: cell(:song).()
  end
end