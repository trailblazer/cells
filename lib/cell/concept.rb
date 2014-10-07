class Cell::Concept < Cell::ViewModel
  abstract!
  self.view_paths = ["app/concepts"]

  # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
  class << self
    def cell_for(name, controller, *args)
      Cell::Builder.new(name.classify.constantize).call(*args).new(controller, *args)
    end

    def controller_path
      # TODO: cache on class level
      # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
      # applies to Comment::Cell, Comment::Cell::Form, etc.
      name.sub(/::Cell/, '').underscore unless anonymous?
    end
  end

  def concept(name, *args, &block)
    self.class.cell(name, parent_controller, *args, &block)
  end

  self_contained!
end