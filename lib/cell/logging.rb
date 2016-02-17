module Cell
  module Logging
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current[:cell_log_runtime] = value
      end

      def self.runtime
        Thread.current[:cell_log_runtime] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def render(event)
        log "Rendered #{event.payload[:template]} by #{event.payload[:cell].class.name}", event
      end

      def call(event)
        log "Rendered #{event.payload[:cell].class.name}##{event.payload[:state]}", event
      end

      private

      def log(message, event)
        self.class.runtime += event.duration
        ::Rails.logger.info color("  #{message} (#{"%.2f" % event.duration}ms)", BLUE)
      end
      LogSubscriber.attach_to :cell
    end

    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

      attr_internal :cell_runtime

      def cleanup_view_runtime
        before_render = Cell::Logging::LogSubscriber.reset_runtime
        runtime = super
        after_render = Cell::Logging::LogSubscriber.reset_runtime
        self.cell_runtime = before_render + after_render
        runtime - after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:cell_runtime] = (cell_runtime || 0) + Cell::Logging::LogSubscriber.runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages, cell_runtime = super, payload[:cell_runtime]
          messages << ("Cells: %.2fms" % cell_runtime.to_f) if cell_runtime
          messages
        end
      end
    end

    ActiveSupport.on_load(:action_controller) do
      include Cell::Logging::ControllerRuntime
    end

    module Instrumentation
      def render(options = {})
        _options = normalize_options(options)
        template_file = find_template(_options).file.gsub(/^app\/\w*\//, "")
        ActiveSupport::Notifications.instrument "render.cell", cell: self, options: _options, template: template_file do
          super(_options)
        end
      end

      def call(state = :show, *args, &block)
        ActiveSupport::Notifications.instrument "call.cell", cell: self, state: state, args: args do
          super
        end
      end
    end

    ViewModel.class_eval do
      include Cell::Logging::Instrumentation
    end
  end
end
