require 'test_helper'

class MusiciansController < ApplicationController
end

class UrlHelperTest < MiniTest::Spec
  let (:controller) { MusiciansController.new.tap { |ctl| ctl.send("request=", ActionDispatch::Request.new({})) } }

  class SongCell < Cell::ViewModel
    self.view_paths = ["test/vm/fixtures"]

    include ActionView::Helpers::FormTagHelper

    def edit
      render
    end

    def with_content_tag
      render
    end
  end

  # URL helpers work in cell instance.
  it { SongCell.new(controller).songs_path.must_equal "/songs" }
  # it { SongCell.new(controller).url_for(Song.new).must_equal "/songs" }

  include TestXml::Assertions # TODO: fix in test_xml.

  # content_tag with HAML.
  it { SongCell.new(controller).with_content_tag.must_equal "" }

  # form helpers with block in block work.
  it { SongCell.new(controller).edit.must_equal_xml_structure "<form><div><input/></div><label/><input/><ul><li/></ul></form>" }
end

# start with content_tag and block (or capture) and find out how sinatra handles that. goal is NOT to use those hacks in haml's action_view_extensions.