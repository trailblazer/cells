# encoding: utf-8
require 'minitest/autorun'

ENV['RAILS_ENV'] = 'test'

require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.

gem_dir       = File.join(File.dirname(__FILE__), '..')
test_app_dir  = File.join(gem_dir, 'test', 'app')

require 'cells'

# Cell::Rails.append_view_path(File.join(test_app_dir, 'cells'))
# Cell::ViewModel.append_view_path(File.join(test_app_dir, 'cells'))


require "cell/test_case"
# Extend TestCase.
MiniTest::Spec.class_eval do
  def assert_not(assertion)
    assert !assertion
  end

  def assert_is_a(klass, object)
    assert object.is_a?(klass)
  end
end

# Enable dynamic states so we can do Cell.class_eval { def ... } at runtime.
class Cell::Rails
  def action_method?(*); true; end
end

require File.join(test_app_dir, 'cells', 'bassist_cell')
require File.join(test_app_dir, 'cells', 'trumpeter_cell')
require File.join(test_app_dir, 'cells', 'bad_guitarist_cell')

require "haml"

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
  def index
    render :text => render_cell(:bassist, :promote)
  end

  def promote
    render :text => render_cell(:trumpeter, :promote)
  end

  def promotion
    render :text => render_cell(:bassist, :provoke)
  end

  def featured
  end

  def featured_with_block
  end

  def skills
    render :text => render_cell(:bassist, :listen)
  end

  def hamlet
  end

  attr_reader :flag
  def promotion_with_block
    html = render_cell(:bassist, :play) do |cell|
      @flag = cell.class
    end

    render :text => html
  end

  def song
    render :inline => %{<%= concept("view_methods_test/cell", "Up For Breakfast").call %>} # TODO: concept doesn't need .call
  end

  def songs
    render :inline => %{<%= concept("view_methods_test/cell", :collection => %w{Alltax Ronny}) %>} # TODO: concept doesn't need .call
  end

  def album
    render :inline => %{<%= cell("view_methods_test/album", "Dreiklang").call %>} # DISCUSS: make .call in #cell?
  end

  def albums
    render :inline => %{<%= cell("view_methods_test/album", :collection => %w{Dreiklang Coaster}) %>}
  end
end