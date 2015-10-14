module Cell
  class Concept < Cell::ViewModel
    abstract!
    self.view_paths = ["app/concepts"]

    # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    class << self
      def controller_path
        @controller_path ||= util.underscore(name.sub(/(::Cell$|Cell::)/, ''))
      end

    private
      def full_cell_name(name) name end
    end

    alias_method :concept, :cell # Concept#concept does exactly what #cell does: delegate to class builder.

    # Get nested cell in instance.
    def cell(name_or_class, model=nil, options={})
      ViewModel.cell(name_or_class, model, options.merge(controller: parent_controller)) # #cell calls need to be delegated to ViewModel.
    end

    self_contained!
  end
end
