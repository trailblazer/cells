require "test_helper"
require "cells/translation"

class TranslationTest < MiniTest::Spec
  class I18nCell < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include Translation

    def greet_relative
      t(".greeting") # gets appended to translation_test.i18n.
    end

    def greet_absolute
      t("translation_test.i18n.greeting")
    end
  end

  I18n.backend = I18n::Backend::KeyValue.new({})
  I18n.backend.store_translations(:en,
                                  { "translation_test.i18n.greeting" => "Translated!",
                                    "cell.friendly.greeting" => "Hello you!" },
                                  escape: false)

  # Translate text specified by an absolute path
  it { I18nCell.new.greet_absolute.must_equal "Translated!" }

  # Translate text specified by an relative path
  it { I18nCell.new.greet_relative.must_equal "Translated!" }


  describe "::translation_path" do
      class ExplicitI18NCell < Cell::ViewModel
      include ActionView::Helpers::TranslationHelper
      include Translation

      self.translation_path = "cell.friendly"

      def show
        t(".greeting")
      end
    end

    it { ExplicitI18NCell.new.().must_equal "Hello you!" }
  end
end
