require 'test_helper'

class InspectTest < Minitest::Spec
  class FakeModel
    def initialize(title)
      @title = title
    end
  end

  def build_model
    InspectTest::FakeModel.new('Title')
  end
  # #inspect
  it do
    cell = Cell::ViewModel.(model_obj = build_model, options = { genre: "Djent" })

    inspection_s = cell.inspect

    assert_match('#<Cell::ViewModel:', inspection_s)
    assert_match("@model=#{model_obj.inspect}", inspection_s)
    assert_match("@title=\"Title\"", inspection_s)
    assert_match("@options=#{options.inspect}", inspection_s)
  end
  it do
    inspection_s = Cell::ViewModel.().inspect

    assert_match('#<Cell::ViewModel:', inspection_s)
    assert_match("@model=nil", inspection_s)
    assert_match("@options={}", inspection_s)
  end

  # black list ivars
  it do
    cell = Cell::ViewModel.(model_obj = build_model, options = { black: 'black, do not' })

    cell.stub(:inspect_blacklist, ['model']) do
      inspection_s = cell.inspect

      assert_match('#<Cell::ViewModel:', inspection_s)
      assert_match("@model=#<InspectTest::FakeModel:#{model_obj.object_id}>", inspection_s)
      assert_match("@options=#{options.inspect}", inspection_s)
    end
  end
end
