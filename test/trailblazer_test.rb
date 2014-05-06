require 'test_helper'

class RecordCell < Cell::Rails
  class SongCell < self
    def show
      render
    end
  end
end

module Cell::Rails::Concept
  def self.cell(name, controller, *args)
    Cell::Builder.new(name.classify.constantize, controller).cell_for(controller, *args)
  end

  module Naming
    module ClassMethods
      def controller_path
        # TODO: cache on class level
        # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
        # applies to Comment::Cell, Comment::Cell::Form, etc.
        name.sub(/::Cell/, '').underscore unless anonymous?
      end
    end
  end

  def self.included(base)
    base.extend Naming::ClassMethods # TODO: separate inherit_view
  end
end

# Trailblazer style:
module Record
  class Cell < Cell::Rails # cell("record")
    include Concept
    # prefix: record/
    #         record/views/
    def show
      render
    end

    # cell(:song, concept: :record)
    class Song < self # cell("record/cell/song")
      include Concept
    # prefix: record/song/
    #         record/song/views/
    #         record/
    #         record/views/
    end

    class Hit < ::Cell::Rails
      include Concept

      inherit_views Record::Cell
    end
  end
end


class ConceptTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  describe "::controller_path" do
    it { Record::Cell.new(@controller).controller_path.must_equal "record" }
    it { Record::Cell::Song.new(@controller).controller_path.must_equal "record/song" }
  end

  describe "#_prefixes" do
    it { Record::Cell.new(@controller)._prefixes.must_equal       ["record"] }
    it { Record::Cell::Song.new(@controller)._prefixes.must_equal ["record/song", "record"] }
  end

  it { Record::Cell.new(@controller).render_state(:show).must_equal "Rock on!" }


  describe "#cell" do
    it { Cell::Rails::Concept.cell("record/cell", @controller).must_be_instance_of(      Record::Cell) }
    it { Cell::Rails::Concept.cell("record/cell/song", @controller).must_be_instance_of  Record::Cell::Song }
    # cell("song", concept: "record/compilation") # record/compilation/cell/song
  end


  describe "::inherit_views" do
    it { Record::Cell::Hit.new(@controller)._prefixes.must_equal ["record/hit", "record"]  }
  end



  # inheriting
  it "inherit play.html.erb from BassistCell" do
    BadGuitaristCell.class_eval do
      def play; render; end
    end
    assert_equal "Doo", render_cell(:bad_guitarist, :play)
  end

  it "inherit show.erb from parent" do
    render_cell("record_cell/song", :show).must_equal "Rock on!"
  end
end