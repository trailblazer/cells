require_relative 'helper'

class MusiciansController < ApplicationController
end

class UrlHelperTest < MiniTest::Spec
  let (:controller) { MusiciansController.new.tap { |ctl| ctl.send("request=", ActionDispatch::Request.new({})) } }
  let (:cellule) { SongCell.new(controller) }

  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

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

    def with_form_tag
      form_tag("/songs") + content_tag(:span) + "</form>"
    end

    include ActionView::Helpers::AssetTagHelper
    def with_link_to
      render
    end

    include ActionView::Helpers::FormHelper
    def with_form_for_block
      render
    end

    def erb_with_form_for_block
      render template_engine: :erb
    end

  private
    def cap
      "yay, #{with_output_buffer { yield } }"
    end
  end


  # URL helpers work in cell instance.
  it { cellule.songs_path.must_equal "/songs" }
  # it { cellule.url_for(Song.new).must_equal "/songs" }

  include TestXml::Assertions # TODO: fix in test_xml.

  # content_tag with HAML.
  it { cellule.with_content_tag.must_equal "<span>Title:\n<div>Still Knee Deep\n</div>\n</span>\n" }

  # form_tag with block in block work.
  it { cellule.edit.must_equal_xml_structure "<form><div><input/></div><label/><input/><ul><li/></ul></form>" }

  # form_tag, no block
  it { cellule.with_form_tag.must_equal_xml_structure "<form><div><input/></div><span/></form>" }

  # form_for with block
  it { cellule.with_form_for_block.must_equal_xml_structure "<form><div><input/></div><input/></form>" }
  # form_for with block in ERB.
  it { cellule.erb_with_form_for_block.must_equal_xml_structure "<form><div><input/></div><input/></form>" }

  # when using yield, haml breaks it (but doesn't escape HTML)
  it { cellule.with_block.must_equal "Nice!\nyay, <b>yeah</b>\n" }

  # capture
  it { cellule.with_capture.must_equal "Nice!\n<b>Great!</b>\n" }

  # there's again escaping happening where it shouldn't be in link_to and rails <= 3.2.
  if Cell.rails_version >= Gem::Version.new('4.0')
    # link_to with block and img_tag
    it { cellule.with_link_to.must_equal "<a href=\"/songs\"><img alt=\"All\" src=\"/images/all.png\" />\n</a>\n" }
  end
end

# start with content_tag and block (or capture) and find out how sinatra handles that. goal is NOT to use those hacks in haml's action_view_extensions.