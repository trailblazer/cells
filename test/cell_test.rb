require "test_helper"

class CellTest < MiniTest::Spec
  class ArtistCell < Cell::Rails
  end
  class SongCell < Cell::Base
    include Cell::OptionsConstructor
  end

  describe "#initialize" do
    it { Class.new(Cell::Base) { include Cell::OptionsConstructor }.new(:song => song=Object.new).song.must_equal song }
    it { Class.new(Cell::Rack) { include Cell::OptionsConstructor }.new(Object, :song => song=Object.new).song.must_equal song }
    it { Class.new(Cell::Rails) { include Cell::OptionsConstructor }.new(Object, :song => song=Object.new).song.must_equal song }
  end

  describe "::create_cell_for" do
    it { Cell::Base.create_cell_for("cell_test/song", :song => song=Object.new).song.must_equal song }
  end

  describe "#cell" do
    it { Cell::Rails.new(Object).cell("cell_test/artist").must_be_instance_of ArtistCell }
    it { Cell::Base.new.cell("cell_test/song").must_be_instance_of SongCell }
  end
end

class OptionsConstructorTest < MiniTest::Spec
  it { Class.new(Cell::Base) { include Cell::OptionsConstructor }.new(:song => song=Object.new).song.must_equal song }
end