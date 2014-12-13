require 'test_helper'


class TemplatesTest < MiniTest::Spec
  Templates = Cell::Templates

  let (:base) { ['test/fixtures'] }

  # existing.
  it { Templates.new[base, ['bassist'], 'play', 'erb'].file.must_equal 'test/fixtures/bassist/play.erb' }

  # not existing.
  it { Templates.new[base, ['bassist'], 'not-here', 'erb'].must_equal nil }


  # different caches for different classes

  # same cache for subclasses

end


class TemplatesCachingTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']

    def show
      render
    end
  end

  # templates are cached once and forever.
  it do
    cell = cell("templates_caching_test/song")

    cell.call(:show).must_equal 'The Great Mind Eraser'

    SongCell.templates.instance_eval do
      def create; raise; end
    end

    # cached, NO new tilt template.
    cell.call(:show).must_equal 'The Great Mind Eraser'
  end
end