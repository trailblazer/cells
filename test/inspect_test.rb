require 'test_helper'

class InspectTest < Minitest::Spec
  class FakeModel
    def initialize(title:)
      @title = title
    end
  end

  def build_model
    InspectTest::FakeModel.new(title: 'Title')
  end
  # #inspect
  it do
    cell = Cell::ViewModel.(model_obj = build_model, options = { genre: "Djent" })

    inspection_s = cell.inspect

    inspection_s.must_match '#<Cell::ViewModel:'
    inspection_s.must_match "@model=#{model_obj.inspect}"
    inspection_s.must_match "@title=\"Title\""
    inspection_s.must_match "@options=#{options.inspect}"
  end
  it do
    inspection_s = Cell::ViewModel.().inspect

    inspection_s.must_match '#<Cell::ViewModel:'
    inspection_s.must_match "@model=nil"
    inspection_s.must_match "@options={}"
  end

  # black list ivars
  it do
    cell = Cell::ViewModel.(model_obj = build_model, options = { black: 'black, do not' })

    cell.stub(:inspect_blacklist, ['model']) do
      inspection_s = cell.inspect

      inspection_s.must_match '#<Cell::ViewModel:'
      inspection_s.must_match "@model=#<InspectTest::FakeModel:#{model_obj.object_id}>"
      inspection_s.must_match "@options=#{options.inspect}"
    end
  end
end
