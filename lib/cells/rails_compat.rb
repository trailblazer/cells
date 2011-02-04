# TODO: remove me when Cells supports 3.1, only.
if Rails::VERSION::MINOR == 0 and Rails::VERSION::TINY <= 3
  module AbstractController
    module Callbacks
      def process_action(method_name, *args)  # Fixed in 3.0.4.
        run_callbacks(:process_action, method_name) do
          super
        end
      end
    end
  end
end
