class Cell::Concept < Cell::ViewModel
  abstract!
  self.view_paths = ["app/concepts"]

  # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
  class << self
    def class_from_cell_name(name)
      name.classify.constantize
    end

    def controller_path
      @controller_path ||= util.underscore(name.sub(/::Cell/, ''))
    end
  end

  alias_method :concept, :cell # the #cell helper to instantiate cells in cells.

  self_contained!
end