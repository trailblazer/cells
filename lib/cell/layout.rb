module Cell
  # Set the layout per cell class. This is used in #render calls. Gets inherited to subclasses.
  module Layout
    def self.included(base)
      base.extend ClassMethods
      base.inheritable_attr :layout_name
    end

    module ClassMethods
      def layout(name)
        self.layout_name = name
      end
    end

    def process_options!(options)
      options[:layout] ||= self.class.layout_name
      super
    end
  end
end