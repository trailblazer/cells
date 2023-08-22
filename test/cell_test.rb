require "test_helper"


require "cells/__erb__"


# Render page, collect headers


class CellTest < Minitest::Spec
  it "what" do
    template = Cell::Erb::Template.new("test/show.erb")
    result = Cell.({template: template})
    assert_equal result, %(<div>show</div>\n)

    template = Cell::Erb::Template.new("test/show_title.erb")
    result = Cell.({template: template, exec_context: Struct.new(:title).new("Epic!")})
    assert_equal result, %(title: Epic!\n)

    template = Cell::Erb::Template.new("test/show_yield.erb")
    result = Cell.({template: template, exec_context: nil}) { "insert me!" }
    assert_equal result, %(yield: insert me!\n)
  end
end
