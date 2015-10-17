require "uber/builder"

module Cell
  module Builder
    def self.included(base)
      base.send :include, Uber::Builder
      base.extend ClassMethods
    end

    module ClassMethods
      def build(*args)
        class_builder.call(*args).new(*args) # Uber::Builder::class_builder.
      end
    end
  end
end
