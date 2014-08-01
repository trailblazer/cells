require 'disposable/twin'
require 'disposable/twin/option'
module Cell
  class Twin < Disposable::Twin
    include Option

    def self.property_names
      representer_class.representable_attrs.collect(&:name)
    end

    module Properties
      def self.included(base)
        base.extend Uber::InheritableAttr
        base.inheritable_attr :twin_class
        base.extend ClassMethods
      end

      module ClassMethods
        def properties(twin_class)
          twin_class.property_names.each { |name| property name }
          self.twin_class = twin_class
        end

        alias_method :twin, :properties
      end

      def initialize(controller, model, options={})
        super(controller, build_twin(model, options))
      end

    private

      def build_twin(*args)
        self.class.twin_class.new(*args)
      end
    end
  end
end