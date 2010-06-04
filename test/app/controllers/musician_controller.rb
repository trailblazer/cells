class MusicianController < ActionController::Base
  def promotion
    render :text => render_cell(:bassist, :play)
  end
  
  def featured
    self.view_paths << File.expand_path(File.join(File.dirname(__FILE__), '../views'))
  end
end