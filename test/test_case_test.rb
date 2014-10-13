require_relative 'helper'

class TestCaseTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
  end

  class Song
    class Cell < Cell::Concept
    end
  end

  let (:song) { Object.new }

  describe "#cell" do
    subject { cell("test_case_test/song", song) }

    it { subject.must_be_instance_of SongCell }
    it { subject.model.must_equal song }
  end


  describe "#concept" do
    subject { concept("test_case_test/song/cell", song) }

    it { subject.must_be_instance_of Song::Cell }
    it { subject.model.must_equal song }
  end


  # capybara support
  class CapybaraCell < Cell::ViewModel
    def show
      "<b>Grunt</b>"
    end
  end

  describe "capybara support" do
    subject { cell("test_case_test/capybara", nil) }

    it { subject.call } # add capybara tests here, @seuros.
  end
end