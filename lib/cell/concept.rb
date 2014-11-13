class Cell::Concept < Cell::ViewModel
  abstract!
  self.view_paths = ["app/concepts"]

  # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
  class << self
    def class_from_cell_name(name)
      name.classify.constantize
    end

    def controller_path
      @controller_path ||= name.sub(/::Cell/, '').underscore
    end
  end

  def concept(name, *args, &block)
    self.class.cell(name, parent_controller, *args, &block)
  end

  self_contained!
end