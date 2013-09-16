require "test_helper"

module Cell::OptionsConstructor
  def process_args(options={})
    options.each do |k, v|
      instance_variable_set("@#{k}", v)
      singleton_class.class_eval { attr_reader k }
    end

    super # Base.
  end
end

class CellTest < MiniTest::Spec
  describe "#initialize" do
    it { Class.new(Cell::Base) { include Cell::OptionsConstructor }.new(:song => song=Object.new).song.must_equal song }
    it { Class.new(Cell::Rack) { include Cell::OptionsConstructor }.new(Object, :song => song=Object.new).song.must_equal song }
    it { Class.new(Cell::Rails) { include Cell::OptionsConstructor }.new(Object, :song => song=Object.new).song.must_equal song }
  end

  describe "::create_cell_for" do
    class SongCell < Cell::Base
      include Cell::OptionsConstructor
    end

    it { Cell::Base.create_cell_for("cell_test/song", :song => song=Object.new).song.must_equal song }
  end
end