module Cell
  class Concept < Cell::ViewModel
    abstract!
    self.view_paths = ["app/concepts"]

    # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    class << self
      def class_from_cell_name(name, controller)
        @cell_class ||= begin
          supports_path = controller.supports_path?
          routes  = controller.respond_to?(:_routes)  && controller._routes
          helpers = controller.respond_to?(:_helpers) && controller._helpers

          Class.new(name.camelize.constantize) do
            if routes
              include routes.url_helpers(supports_path)
              include routes.mounted_helpers
            end

            if helpers
              include helpers
            end
          end
        end
      end

      def controller_path
        @controller_path ||= util.underscore(name.sub(/(::Cell$|Cell::)/, ''))
      end
    end

    alias_method :concept, :cell # Concept#concept does exactly what #cell does: delegate to class builder.

    # Get nested cell in instance.
    def cell(name, model=nil, options={})
      ViewModel.cell(name, model, options.merge(controller: parent_controller)) # #cell calls need to be delegated to ViewModel.
    end

    self_contained!
  end
end
