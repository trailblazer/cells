module Cell
  class Concept < Cell::ViewModel
    abstract!
    self.view_paths = ["app/concepts"]

    # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    class << self
      def class_from_cell_name(name)
        name.camelize.constantize
      end

      def controller_path
        @controller_path ||= util.underscore(name.sub(/(::Cell$|Cell::)/, ''))
      end
    end

    alias_method :concept, :cell # Concept#concept does exactly what #cell does: delegate to class builder.

    # Get nested cell in instance.
    def cell(name, model=nil, options={})
      ViewModel.cell(name, model, options.merge(context: @options[:context])) # #cell calls need to be delegated to ViewModel.
    end

    self_contained!
  end
end
