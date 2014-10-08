require 'byebug' rescue LoadError
require 'minitest/autorun'
require 'test_xml/mini_test'

ENV['RAILS_ENV'] = 'test'

require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.

require 'cells'
require "cell/test_case"

MiniTest::Spec.class_eval do
  include Cell::TestCase::Helpers
end

class BassistCell < Cell::ViewModel
end


ActiveSupport::TestCase.class_eval do # this is only needed in integration tests (AC::TestCase).
  def fix_relative_url_root
    return unless Cell.rails_version.~("3.0")

    @controller.config.instance_eval do
      def relative_url_root
        ""
      end
    end
end
end


class MusicianController < ActionController::Base
  def view_with_concept_with_show
    render :inline => %{<%= concept("view_extensions_test/cell", "Up For Breakfast", volume: 1).show %>} # TODO: concept doesn't need .call
  end

  def view_with_concept_without_call
    render :inline => %{<%= concept("view_extensions_test/cell", "A Tale That Wasn't Right") %>} # this tests ViewModel#to_s.
  end

  def view_with_concept_with_call
    render :inline => %{<%= concept("view_extensions_test/cell", "A Tale That Wasn't Right").call %>}
  end

  def view_with_cell_with_call
    render :inline => %{<%= cell("view_extensions_test/song", "A Tale That Wasn't Right").call %>}
  end

  def action_with_concept_with_call
    render text: concept("view_extensions_test/cell", "A Tale That Wasn't Right").call
  end

  def action_with_cell_with_call
    render text: cell("view_extensions_test/song", "A Tale That Wasn't Right").call
  end
end