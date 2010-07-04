class MusicianController < ActionController::Base
  def promotion
    render :text => render_cell(:bassist, :play)
  end
  
  def featured
    self.view_paths << File.expand_path(File.join(File.dirname(__FILE__), '../views'))
  end
  
  def skills
    render :text => render_cell(:bassist, :listen)
  end
  

  def action_method?(name); true; end ### FIXME: fixes NameError: undefined local variable or method `_router' for MusicianController:Class
end