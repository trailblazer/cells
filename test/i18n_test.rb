require 'test_helper'

class I18nTest < MiniTest::Spec
  class I18nCell < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper

    def translate_relative(path=nil)
      @virtual_path = path if path
      t('.text')
    end

    def translate_absolute
      t('test.text')
    end
  end

  I18n.backend = I18n::Backend::KeyValue.new({})
  I18n.backend.store_translations(:en,
                                  { 'test.text' => 'test text' },
                                  escape: false)

  # Translate text specified by an absolute path
  it { I18nCell.new.translate_absolute.must_equal 'test text' }

  # Translate text specified by an relative path
  it { I18nCell.new.translate_relative.must_equal 'test text' }

  # Translate text specified by an relative path, explicitly set
  it { I18nCell.new.translate_relative('test').must_equal 'test text' }

end
