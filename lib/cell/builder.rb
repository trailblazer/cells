require "uber/builder"

module Cell
  module Builder
    def self.included(base)
      base.send :include, Uber::Builder
      base.extend ClassMethods
    end

    module ClassMethods
      def build(*args)
        build!(self, *args).new(*args) # Uber::Builder#build!.
      end
    end
  end
end
