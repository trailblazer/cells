require 'test_helper'

class TestCaseTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    def show
      "Give It All!"
    end
  end

  class Song
    class Cell < Cell::Concept
    end
  end

  let (:song) { Object.new }

  # #cell returns the instance
  describe "#cell" do
    subject { cell("test_case_test/song", song) }

    it { assert_instance_of SongCell, subject }
    it { assert_equal song, subject.model }

    it { assert_equal "Give It All!Give It All!", cell("test_case_test/song", collection: [song, song]).() }
  end

  describe "#concept" do
    subject { concept("test_case_test/song/cell", song) }

    it { assert_instance_of Song::Cell, subject }
    it { assert_equal song, subject.model }
  end
end

# capybara support
require "capybara"

class CapybaraTest < Minitest::Spec
  class CapybaraCell < Cell::ViewModel
    def show
      "<b>Grunt</b>"
    end
  end

  describe "capybara support" do
    subject { cell("capybara_test/capybara", nil) }

    before { Cell::Testing.capybara = true  } # yes, a global switch!
    after  { Cell::Testing.capybara = false }

    it { assert subject.(:show).has_selector?('b') }
    it { assert cell("capybara_test/capybara", collection: [1, 2]).().has_selector?('b') }

    # FIXME: this kinda sucks, what if you want the string in a Capybara environment?
    it { assert_match "<b>Grunt</b>", subject.(:show).to_s }
  end
end
