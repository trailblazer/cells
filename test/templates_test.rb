require 'test_helper'

class TemplatesTest < Minitest::Spec
  Templates = Cell::Templates

  # existing.
  it { assert_equal 'test/fixtures/bassist/play.erb', Templates.new[['test/fixtures/bassist'], 'play.erb', {template_class: Cell::Erb::Template}].file }

  # not existing.
  it { assert_nil(Templates.new[['test/fixtures/bassist'], 'not-here.erb', {}]) }
end

class TemplatesCachingTest < Minitest::Spec
  class SongCell < Cell::ViewModel
    self.view_paths = ['test/fixtures']
    # include Cell::Erb

    def show
      render
    end
  end

  # templates are cached once and forever.
  it do
    cell = cell("templates_caching_test/song")

    assert_equal 'The Great Mind Eraser', cell.call(:show)

    SongCell.templates.instance_eval do
      def create; raise; end
    end

    # cached, NO new tilt template.
    assert_equal 'The Great Mind Eraser', cell.call(:show)
  end
end
