require 'test_helper'

class Musician
    extend ActiveModel::Naming

    def persisted?
      false
    end
  end

class Cell::Rails
  module ViewModel

  def initialize(*)
    super
    singleton_class.instance_eval do
      define_method :show do |*args|
        @_action_name = :show
        super(*args)
      end
    end
  end

  private
    def view_context
      self
    end
  end
end

class ViewModelTest < MiniTest::Spec
  # change constructor so we can test new(comment).title
  # cell.show
  # views :show, :create #=> wrap in render_state(:show, *)
  include Cell::TestCase::TestMethods

  class CommentsCell < Cell::Rails
    include Cell::Rails::ViewModel
    include ActionView::Helpers::UrlHelper

    def show(local)
      render :locals => {:local => local}
    end

    def title
      "Amazing News!"
    end
    # override in subclass and call super (by ggg).
  end

  let (:html) { "<h1>\"Comments from <a href=\"/musicians\">Amazing News!</a>\"</h1>\nYo!\n" }
  it "what" do
    #render_cell("view_model_test/comments", :show).must_equal html
  end

  it "allows calls to state methods directly" do
    skip
    cell("view_model_test/comments").show("Yo!").must_equal html
  end

  it "accepts constructor hash" do

  end
end