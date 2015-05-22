# Used in rspec-cells, etc.
module Cell
  module Testing
    def cell(name, *args)
      cell_for(ViewModel, name, *args)
    end

    def concept(name, *args)
      cell_for(Concept, name, *args)
    end

  private
    def cell_for(baseclass, name, *args)
      cell = baseclass.cell_for(name, controller, *args)
      cell.extend(Capybara) if Object.const_defined?(:"Capybara") # i think 99.9% of people use Capybara.
      cell
    end

    module Capybara
      def call(*)
        ::Capybara.string(super)
      end
    end



    # Rails specific.
    def controller
      # TODO: test without controller.
      return unless self.class.controller_class

      # TODO: test with controller.
      self.class.controller_class.new.tap do |ctl|
        ctl.request = ActionController::TestRequest.new
        ctl.instance_variable_set :@routes, Rails.application.routes.url_helpers
      end
    end

    def self.included(base)
      base.class_eval do
        extend Uber::InheritableAttr
        inheritable_attr :controller_class

        def self.controller(name)
          self.controller_class = name
        end
      end
    end

  end
end