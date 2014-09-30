require 'test_helper'

class TestCaseTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
  end

  let (:song) { Object.new }

  describe "#cell" do
    subject { cell("test_case_test/song", song) }

    it { subject.must_be_instance_of SongCell }
    it { subject.model.must_equal song }
  end
end