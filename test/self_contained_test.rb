require 'test_helper'

class AlbumCell < Cell::Rails
  self_contained!

  def cover
    @title = "The Sufferer & The Witness"
    render
  end
end

unless Cell.rails3_0?

  class SelfContainedTest < MiniTest::Spec
    include Cell::TestCase::TestMethods

    let (:album) { cell(:album) }

    it "renders views from album/views/" do
     album.render_state(:cover).must_equal "<h3>The Sufferer &amp; The Witness</h3>\n"
    end
  end

end