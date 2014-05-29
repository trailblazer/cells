require 'test_helper'

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

ActionController::TestCase.class_eval do
  def png_src
    return "/images/me.png" if Cell.rails_version >= 4.0
    return "/assets/me.png" if Cell.rails_version >= 3.1
    "/images/me.png"
  end
end

class ControllerMethodsTest < ActionController::TestCase
  tests MusicianController

  class SongCell < Cell::Rails
    include Cell::OptionsConstructor
  end

  test "#render_cell" do
    fix_relative_url_root

    get 'promotion'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"#{png_src}\" />", @response.body
  end

  test "#render_cell with arbitrary options" do
    BassistCell.class_eval do
      def enjoy(what, where="the bar")
        render :text => "I like #{what} in #{where}."
      end
    end

    @controller.instance_eval do
      def promotion
        render :text => render_cell(:bassist, :enjoy, "The Stranglers", "my room")
      end
    end
    get 'promotion'
    assert_equal "I like The Stranglers in my room.", @response.body
  end

  test "#render_cell with block" do
    get 'promotion_with_block'
    assert_equal "Doo",       @response.body
    assert_equal BassistCell, @controller.flag
  end

  test "#cell" do
    @controller.cell(:bassist).must_be_instance_of BassistCell
  end

  test "#cell with options" do
    @controller.cell("controller_methods_test/song", :title => "We Called It America").
      title.must_equal "We Called It America"
  end

  if Cell.rails_version >= "5.0" # TODO: make run.
    test "#render_cell for engine" do
      @controller.render_cell(:label, :show).must_equal "Fat Wreck"
    end
  end






 test "pass url_helpers to the cell instance" do
    assert_equal "/musicians", BassistCell.new(@controller).musicians_path
  end

  test "allow cells to use url_helpers" do
    get "index"
    assert_response :success
    assert_equal "Find me at <a href=\"/musicians\">vd.com</a>\n", @response.body
  end

  test "delegate #url_options to the parent_controller" do
    @controller.instance_eval do
      def default_url_options
        {:host => "cells.rails.org"}
      end
    end

    assert_equal "http://cells.rails.org/musicians", BassistCell.new(@controller).musicians_url
  end

  test "allow cells to use *_url helpers when mixing in AC::UrlFor" do
    get "promote"
    assert_response :success
    assert_equal "Find me at <a href=\"http://test.host/musicians\">vd.com</a>\n", @response.body
  end

  test "allow cells to use #config" do
    BassistCell.class_eval do
      def provoke; render; end
    end

    fix_relative_url_root

    get "promotion"
    assert_response :success
    assert_equal "That's me, naked <img alt=\"Me\" src=\"#{png_src}\" />", @response.body
  end
end


class ViewMethodsTest < ActionController::TestCase
  tests MusicianController

  test "#cell_for" do
    @controller.instance_eval do
      def title
      end
    end

    get :title
    @response.body.must_equal "First Call"
  end

  test "#render_cell" do
    fix_relative_url_root

    get 'featured'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"#{png_src}\" />", @response.body
  end

  test "#render_cell with a block" do
    get 'featured_with_block'
    assert_equal "Boing in D from BassistCell\n", @response.body
  end

  test "#render_cell in a haml view" do
    fix_relative_url_root

    get 'hamlet'
    assert_equal "That's me, naked <img alt=\"Me\" src=\"#{png_src}\" />\n", @response.body
  end



  unless ::Cell.rails_version.~("3.0")

    # concept -------------------
    class Cell < Cell::Concept
      def show
        render :text => "<b>#{model}</b>"
      end


      class Collection < ::Cell::Concept
        def show
          concept("view_methods_test/cell", "Dreiklang").call
        end

        def collection
          concept("view_methods_test/cell", :collection => %w{Dreiklang Coaster})
        end
      end
    end

    # Concept#concept(:album, "Dreiklang").call
    test "Concept#cell" do # FIXME: move to HelperTest.
      Cell::Collection.new(@controller).call.must_equal "<b>Dreiklang</b>"
    end

    # Concept#concept(:album, collection: [])
    test "Concept#cell collection: []" do # FIXME: move to HelperTest.
      Cell::Collection.new(@controller).call(:collection).must_equal "<b>Dreiklang</b>\n<b>Coaster</b>"
    end


    # concept(:song, "Alltax").call
    test "#concept" do
      get :song
      @response.body.must_equal "<b>Up For Breakfast</b>"
    end

    # concept(:song, collection: [..])
    test "#concept with collection" do
      get :songs
      @response.body.must_equal "<b>Alltax</b>\n<b>Ronny</b>"
    end



    # view model ------------------
    class AlbumCell < ::Cell::ViewModel
      def show
        "<b>#{model}</b>"
      end
    end

    class AlbumsCell < ::Cell::ViewModel
      def show
        cell("view_methods_test/album", "Dreiklang").call
      end

      def collection
        cell("view_methods_test/album", :collection => %w{Dreiklang Coaster})
      end
    end

    # ViewModel#cell(:album, "Dreiklang").call
    test "ViewModel#cell" do # FIXME: move to HelperTest.
      AlbumsCell.new(@controller).call.must_equal "<b>Dreiklang</b>"
    end

    test "ViewModel#cell collection: []" do # FIXME: move to HelperTest.
      AlbumsCell.new(@controller).call(:collection).must_equal "<b>Dreiklang</b>\n<b>Coaster</b>"
    end


    # cell(:album, "Dreiklang").call
    test "#cell for view model" do
      get :album
      @response.body.must_equal "<b>Dreiklang</b>"
    end

    # cell(:album, collection: [..])
    test "#cell with collection for view model" do
      get :albums
      @response.body.must_equal "<b>Dreiklang</b>\n<b>Coaster</b>"
    end
  end


  test "make params (and friends) available in a cell" do
    BassistCell.class_eval do
      def listen
        render :text => "That's a #{params[:note]}"
      end
    end
    get 'skills', :note => "D"
    assert_equal "That's a D", @response.body
  end

  test "respond to #config" do
    BassistCell.class_eval do
      def listen
        render :view => 'contact_form'  # form_tag internally calls config.allow_forgery_protection
      end
    end
    get 'skills'

    @response.body.must_match /<form.*action="musician\/index"/
  end
end
