require "test_helper"


require "cells/__erb__"


# Render page, collect headers


class CellTest < Minitest::Spec
  it "low-level API" do
    template = Cell::Erb::Template.new("test/show.erb")
    result = Cell.({template: template})
    assert_equal result.to_s, %(<div>show</div>\n)

    template = Cell::Erb::Template.new("test/show_title.erb")
    result = Cell.({template: template, exec_context: Struct.new(:title).new("Epic!")})
    assert_equal result.to_s, %(title: Epic!\n)

    template = Cell::Erb::Template.new("test/show_yield.erb")
    result = Cell.({template: template, exec_context: nil}) { "insert me!" }
    assert_equal result.to_s, %(yield: insert me!\n)
  end

  it "can return variables in Result" do
    exec_context = {headers: []} # {exec_context} needs to expose {#to_h} (which is implemented in almost any object, anyway)

    template = Cell::Erb::Template.new("test/show.erb")
    result = Cell.({template: template, exec_context: exec_context})

    assert_equal result.to_s, %(<div>show</div>\n)
    assert_equal result.to_h.inspect, %({:headers=>[]})
  end
end
