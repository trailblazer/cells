ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/environment'

require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]
require "rails/test_help" # adds stuff like @routes, etc.

require 'cells'
require "cells-erb"

Cell::ViewModel.send(:include, Cell::Erb) if Cell.const_defined?(:Erb) # FIXME: should happen in inititalizer.

MiniTest::Spec.class_eval do
  include Cell::Testing
end

class BassistCell < Cell::ViewModel
  self.view_paths = ['test/fixtures']
end

class MusicianController < ActionController::Base
  def view_with_concept_with_show
    render inline: %{<%= concept("view_extensions_test/cell", "Up For Breakfast", volume: 1).show %>} # TODO: concept doesn't need .call
  end

  def view_with_concept_without_call
    render inline: %{<%= concept("view_extensions_test/cell", "A Tale That Wasn't Right") %>} # this tests ViewModel#to_s.
  end

  def view_with_concept_with_call
    render inline: %{<%= concept("view_extensions_test/cell", "A Tale That Wasn't Right").call %>}
  end

  def view_with_cell_with_call
    render inline: %{<%= cell("view_extensions_test/song", "A Tale That Wasn't Right").call %>}
  end

  def action_with_concept_with_call
    render text: concept("view_extensions_test/cell", "A Tale That Wasn't Right").call
  end

  def action_with_cell_with_call
    render text: cell("view_extensions_test/song", "A Tale That Wasn't Right").call
  end
end

Rails.backtrace_cleaner.remove_silencers! # YES, stacktraces are awesome!