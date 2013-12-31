require "test_helper"

class CachedCell < Cell::Rails

  class ProcVersionerError < RuntimeError; end
  class MethodVersionerError < RuntimeError; end

  cache :state_with_proc_versioner do
    raise ProcVersionerError
  end
  cache :state_with_method_versioner, :method_versioner

  def state_with_proc_versioner
    render
  end
  def state_with_method_versioner
    render
  end

  private

  def method_versioner
    raise MethodVersionerError
  end
end


class CellCachingVersionerTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  describe "#state_with_proc_versioner" do
    it { proc { render_cell(:cached, :state_with_proc_versioner) }.must_raise CachedCell::ProcVersionerError }
  end
  describe "#state_with_method_versioner" do
    it { proc { render_cell(:cached, :state_with_method_versioner) }.must_raise CachedCell::MethodVersionerError }
  end
end
