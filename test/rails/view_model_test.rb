require 'test_helper'

class Musician
    extend ActiveModel::Naming

    def persisted?
      false
    end
  end

class ViewModelTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  class CommentsCell < Cell::Rails
    include ActionView::Helpers::UrlHelper

    def show
      render :locals => {:local => "Yo!"}
    end

    def title
      "Amazing News!"
    end

  private
    def view_context
      self
    end
  end

  it "what" do
    render_cell("view_model_test/comments", :show).must_equal "<h1>\"Comments from <a href=\"/musicians\">Amazing News!</a>\"</h1>\nYo!\n"
  end
end