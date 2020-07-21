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

    _(inspection_s).must_match '#<Cell::ViewModel:'
    _(inspection_s).must_match "@model=#{model_obj.inspect}"
    _(inspection_s).must_match "@title=\"Title\""
    _(inspection_s).must_match "@options=#{options.inspect}"
  end
  it do
    inspection_s = Cell::ViewModel.().inspect

    _(inspection_s).must_match '#<Cell::ViewModel:'
    _(inspection_s).must_match "@model=nil"
    _(inspection_s).must_match "@options={}"
  end

  # black list ivars
  it do
    cell = Cell::ViewModel.(model_obj = build_model, options = { black: 'black, do not' })

    cell.stub(:inspect_blacklist, ['model']) do
      inspection_s = cell.inspect

      _(inspection_s).must_match '#<Cell::ViewModel:'
      _(inspection_s).must_match "@model=#<InspectTest::FakeModel:#{model_obj.object_id}>"
      _(inspection_s).must_match "@options=#{options.inspect}"
    end
  end
end
