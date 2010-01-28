# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[test_helper])
require File.join(File.dirname(__FILE__), *%w[app cells test_cell])

class CaptureTest < ActionController::TestCase
  tests CellsTestController

  def setup
    super

    CellsTestController.class_eval do
      def test_capture
        @cell_content = render_cell(:test, :state_invoking_capture)

        # captured_block comes from the cell view:
        render :inline => '<h3><%= @captured_block %></h3>' << @cell_content
      end

      def test_content_for
        @cell_content = render_cell(:test, :state_invoking_content_for)

        # :js comes from the cell views:
        render :inline => '<pre><%= yield :js %></pre>' << @cell_content
      end
    end
  end

  def test_global_capture
    TestCell.class_eval do
      helper ::Cells::Helpers::CaptureHelper
      def state_invoking_capture
        render
      end
    end

    get :test_capture

    assert_select 'h1', ''
    assert_select 'h2', 'captured!'
    assert_select 'h3', 'captured!', 'captured block not visible in controller'
  end

  def test_global_content_for
    TestCell.class_eval do
      helper ::Cells::Helpers::CaptureHelper
      def state_invoking_content_for
        render
      end
      def state_invoking_content_for_twice
        render
      end
    end

    get :test_content_for

    assert_select 'js',   ''
    assert_select 'pre',  "\nfirst line\n\nsecond line\n\nthird line\n"
  end
end
