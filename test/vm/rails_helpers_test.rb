require 'test_helper'

class MusiciansController < ApplicationController
end

class UrlHelperTest < MiniTest::Spec
  let (:controller) { MusiciansController.new.tap { |ctl| ctl.send("request=", ActionDispatch::Request.new({})) } }
  let (:cell) { SongCell.new(controller) }

  class SongCell < Cell::ViewModel
    self.view_paths = ["test/vm/fixtures"]

    include ActionView::Helpers::FormTagHelper

    def edit
      render
    end

    def with_content_tag
      render
    end

    def with_block
      render
    end

    def with_capture
      render
    end

  private
    def cap
      "yay, #{with_output_buffer { yield } }"
    end
  end


  # URL helpers work in cell instance.
  it { cell.songs_path.must_equal "/songs" }
  # it { cell.url_for(Song.new).must_equal "/songs" }

  include TestXml::Assertions # TODO: fix in test_xml.

  # content_tag with HAML.
  it { cell.with_content_tag.must_equal "<span>Title:\n<div>Still Knee Deep\n</div>\n</span>\n" }

  # form helpers with block in block work.
  it { cell.edit.must_equal_xml_structure "<form><div><input/></div><label/><input/><ul><li/></ul></form>" }



  # when using yield, haml breaks it (but doesn't escape HTML)
  it("yyy") { cell.with_block.must_equal "Nice!\nyay, <b>yeah</b>\n" }

  # capture
  it( "xxx") { cell.with_capture.must_equal "Nice!\n<b>Great!</b>\n" }
end

# start with content_tag and block (or capture) and find out how sinatra handles that. goal is NOT to use those hacks in haml's action_view_extensions.