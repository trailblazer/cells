# encoding: utf-8

module Cells
  module Cell
    class View < ::ActionView::Base

      attr_accessor :cell
      alias_method :render_for, :render

      # Tries to find the passed template in view_paths. Returns the view on success-
      # otherwise it will throw an ActionView::MissingTemplate exception.
      def try_picking_template_for_path(template_path)
        self.view_paths.find_template(template_path, template_format)
      end

      ### TODO: this should just be a thin helper.
      ### dear rails folks, could you guys please provide a helper #render and an internal #render_for
      ### so that we can overwrite the helper and cleanly reuse the internal method? using the same
      ### method both internally and externally sucks ass.
      def render(options = {}, local_assigns = {}, &block)
        ### TODO: we have to find out if this is a call to the cells #render method, or to the rails
        ###       method (e.g. when rendering a layout). what a shit.
        if (options.keys & [:view, :state]).present?  ### TODO: is there something like has_keys?
          # that's better: simply delegate render back to the cell/controller.
          return cell.render(options)
        end

        # rails compatibility we should get rid of:
        if partial_path = options[:partial]
          # adds the cell name to the partial name.
          options[:partial] = expand_view_path(partial_path)
        end

        super(options, local_assigns, &block)
      end

      def expand_view_path(path)
        path = "#{cell.cell_name}/#{path}" unless path.include?('/')
        path
      end

      # this prevents cell ivars from being overwritten by same-named
      # controller ivars.
      # we'll hopefully get a cleaner way, or an API, to handle this in rails 3.
      def _copy_ivars_from_controller #:nodoc:
        if @controller
          variables = @controller.instance_variable_names
          variables -= @controller.protected_instance_variables if @controller.respond_to?(:protected_instance_variables)
          variables -= assigns.keys.collect { |key| "@#{key}" } # cell ivars override controller ivars.
          variables.each { |name| instance_variable_set(name, @controller.instance_variable_get(name)) }
        end
      end
    end
  end
end
