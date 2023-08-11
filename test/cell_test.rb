require "test_helper"

require "tilt/template"
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


class CellTest < Minitest::Spec
  it "what" do
    template = Cell::Erb::Template.new("test/show.erb")
    result = Cell.({template: template})
    assert_equal result, %(<div>show</div>\n)

    template = Cell::Erb::Template.new("test/show_title.erb")
    result = Cell.({template: template, exec_context: Struct.new(:title).new("Epic!")})
    assert_equal result, %(title: Epic!\n)
  end
end
