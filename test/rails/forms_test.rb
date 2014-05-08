require 'test_helper'

class FormsTest < MiniTest::Spec
  class Song < OpenStruct
    extend ActiveModel::Naming
  end

  include Cell::TestCase::TestMethods

  let (:bassist) { cell(:bassist) }

  it "renders input fields within the form tag with ERB" do
    bassist.instance_eval do
      def form_for
        render
      end
    end

    html = bassist.render_state(:form_for)

    html.must_match Regexp.new("<form.+[name].+<\/form>", Regexp::MULTILINE)
  end

  class SongFormCell < BassistCell
    include ViewModel
    include ActionView::Helpers::FormHelper

    def form
      render :view => :form_for
    end

    def dom_class(*)

    end

    def dom_id(*)

    end
  end

  it "renders input fields within the form tag with ERB and ViewModel" do
    skip if ::Cell.rails_version.~("3.0")

    html = SongFormCell.new(@controller).form
    puts html.to_s

    html.must_match Regexp.new("<form.+<input id=\"forms_test_song_name\".+<\/form>", Regexp::MULTILINE)
  end


  class HamlSongFormCell < BassistCell
    include ViewModel
    include ActionView::Helpers::FormHelper

    def form
      render :view => :form_for_in_haml
    end

    def dom_class(*)

    end

    def dom_id(*)

    end
  end

  it "renders input fields within the form tag with HAML and ViewModel" do
    skip
    html = HamlSongFormCell.new(@controller).form
    puts html.to_s

    html.must_match Regexp.new("<form.+<input id=\"forms_test_song_name\".+<\/form>", Regexp::MULTILINE)
  end
end