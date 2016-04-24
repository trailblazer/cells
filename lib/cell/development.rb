module Cell
  module Development
    def self.included(base)
      base.instance_eval do
        def templates
          Templates.new
        end
      end
    end

    module Clearable
      def self.included(base)
        base.instance_eval do
          def templates
            @@templates ||= Templates.new
          end

          def clear_templates!
            @@templates = nil
          end
        end
      end
    end
  end
end