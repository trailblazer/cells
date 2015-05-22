# Used in rspec-cells, etc.
module Cell
  # Builder methods and Capybara support.
  # This gets included into Test::Unit, MiniTest::Spec, etc.
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
      cell.extend(Capybara) if Cell::Testing.capybara? # leaving this here as most people use Capybara.
      cell
    end


    # Set this to true if you have Capybara loaded. Happens automatically in Cell::TestCase.
    def self.capybara=(value)
      @capybara = value
    end

    def self.capybara?
      @capybara
    end

    # Extends ViewModel#call by injecting Capybara support.
    module Capybara
      module ToS
        def to_s
          native.to_s
        end
      end

      def call(*)
        ::Capybara.string(super).extend(ToS)
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