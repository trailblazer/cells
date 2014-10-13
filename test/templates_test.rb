require_relative 'helper'


class TemplatesTest < MiniTest::Spec
  Templates = Cell::Templates

  let (:base) { ['test/fixtures'] }

  # existing.
  it { Templates.new[base, ['bassist'], 'play', 'haml'].file.must_equal 'test/fixtures/bassist/play.haml' }

  # not existing.
  it { Templates.new[base, ["bassist"], "not-here", "haml"].must_equal nil }


  # different caches for different classes

  # same cache for subclasses

end


class TemplatesCachingTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ["test/vm/fixtures"]

    def show
      render
    end
  end

  # templates are cached once and forever.
  it do
    cell = cell("templates_caching_test/song")

    cell.call(:show).must_equal "The Great Mind Eraser\n"

    SongCell.templates.instance_eval do
      def create; raise; end
    end

    # cached, NO new tilt template.
    cell.call(:show).must_equal "The Great Mind Eraser\n"
  end
end