require "erbse"

class Cell
  # Erb contains helpers that are messed up in Rails and do escaping.
  module Erb
    # Erbse-Tilt binding. This should be bundled with tilt. # 1.4. OR should be tilt-erbse.
    class Template < Tilt::Template
      def self.engine_initialized?
        defined? ::Erbse::Engine
      end

      def initialize_engine
        require_template_library "erbse"
      end

      def prepare
        @template = ::Erbse::Engine.new # we also have #options here.
      end

      def precompiled_template(locals)
        # puts @template.call(data)
        @template.call(data)
      end
    end
  end
end
