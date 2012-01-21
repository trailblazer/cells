module Cell
  # Makes #options available in Cells 3.7, which was removed in favor of state-args.
  # Note that Deprecations are only available for Cell::Rails.
  module Deprecations
    extend ActiveSupport::Concern

    included do
      attr_reader :options
    end


    module ClassMethods
      def build_for(controller, *args)
        build_class_for(controller, *args).
        new(controller, *args)
      end
    end


    def initialize(parent_controller, *args)
      super(parent_controller)  # the real Rails.new.
      setup_backwardibility(*args)
    end

    # Some people still like #options and assume it's a hash.
    def setup_backwardibility(*args)
      @_options = (args.first.is_a?(Hash) and args.size == 1) ? args.first : args
      @options  = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(@_options, "#options is deprecated and was removed in Cells 3.7. Please use state-args.")
    end

    def render_state(state, *args)
      return super(state, *args) if state_accepts_args?(state)
      super(state)  # backward-compat.
    end

    def state_accepts_args?(state)
      method(state).arity != 0
    end

  end
end
