require File.join(File.dirname(__FILE__), '/../test_helper')
require 'cells/sinatra'

module OctaveHelper
  def pitch(note)
    "#{note}'"
  end
end


class SinatraHelperTest < ActiveSupport::TestCase
  context "A cell with helper" do
    should "respond to helper methods on instance level" do
      assert_not cell(:singer).respond_to?(:pitch)
      
      SingerCell.class_eval { helpers OctaveHelper }
      assert cell(:singer).respond_to?(:pitch)
    end
  end
end