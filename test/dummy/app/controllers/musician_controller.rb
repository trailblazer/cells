class MusicianController < ActionController::Base
  def index
    render :text => render_cell(:bassist, :promote)
  end
            
  def promotion
    render :text => render_cell(:bassist, :provoke)
  end
  
  def featured
  end
  
  def skills
    render :text => render_cell(:bassist, :listen)
  end
  
  def hamlet
  end

  #def action_method?(name); true; end ### FIXME: fixes NameError: undefined local variable or method `_router' for MusicianController:Class
end