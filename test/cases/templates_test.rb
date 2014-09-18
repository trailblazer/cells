require 'test_helper'


class TemplatesTest < MiniTest::Spec
  Templates = Cell::Templates

  let (:base) { ['test/fixtures'] }

  # existing.
  it { Templates.new[base, ['bassist'], 'play', 'haml'].file.must_equal 'test/fixtures/bassist/play.haml' }

  # not existing.
  it { Templates.new[base, ["bassist"], "not-here", "haml"].must_equal nil }
end