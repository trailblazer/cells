require 'minitest/autorun'
require 'test_xml/mini_test'
require "haml"

ENV['RAILS_ENV'] = 'test'

require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.

require 'cells'

# Cell::Rails.append_view_path(File.join(test_app_dir, 'cells'))
# Cell::ViewModel.append_view_path(File.join(test_app_dir, 'cells'))


require "cell/test_case"
# Extend TestCase.
MiniTest::Spec.class_eval do
  def cell(name, *args) # todo: FUCKING REMOVE THIS HORRIBLE SHIT CONTROLLER!
    Cell::ViewModel.cell_for(name, nil, *args) # TODO: move to TestCase.
  end
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
    render :inline => %{<%= concept("view_extensions_test/cell", "A Tale That Wasn't Right").call %>} # this tests ViewModel#to_s.
  end



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