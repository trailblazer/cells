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

    def output_buffer
      @output_buffer ||= []
    end
  end

  # URL helpers work in cell instance.
  it { SongCell.new(controller).songs_path.must_equal "/songs" }
  # it { SongCell.new(controller).url_for(Song.new).must_equal "/songs" }

  include TestXml::Assertions # TODO: fix in test_xml.

  # form helpers with block in block work.
  it { SongCell.new(controller).edit.must_equal_xml_structure "<form><div><input/></div><label/><input/><ul><li/></ul></form>" }
end