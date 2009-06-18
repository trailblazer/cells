require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

class ACell < Cell::Base
  def existing_view
    @a = "a"; nil
  end
  
  def not_existing_view
    @a = "a"; nil
  end
end

class BCell < ACell
  def existing_view
    @b = "b"; nil
  end
  
  def not_existing_view
    @b = "b"; nil
  end
end

class RenderTest < ActionController::TestCase
  include CellsTestMethods
  include Cell::ActionView
  
  def test_return_nil_with_locally_existing_view
    assert_equal "A/existing_view/a", render_cell(:a, :existing_view)
    assert_equal "B/existing_view/b", render_cell(:b, :existing_view)
  end
  
  def test_return_nil_with_inherited_view
    BCell.class_eval do   
      def inherited_view;   @a = "b"; nil; end
    end
    assert_equal "A/inherited_view/b", render_cell(:b, :inherited_view)
  end
  
  def test_return_nil_with_not_existing_view
    assert_raises ActionView::MissingTemplate do render_cell(:a, :not_existing_view)  end
    assert_raises ActionView::MissingTemplate do render_cell(:b, :not_existing_view)  end
  end
  
  def test_render_without_arguments_with_locally_existing_view
    ACell.class_eval do
      def existing_view;    @a = "a"; render; end
    end
    BCell.class_eval do
      def existing_view;    @b = "b"; render; end
    end
    assert_equal "A/existing_view/a", render_cell(:a, :existing_view)
    assert_equal "B/existing_view/b", render_cell(:b, :existing_view)
  end
  
  def test_render_passing_view_with_locally_existing_view
    ACell.class_eval do
      def existing_view;    @a = "a"; render :view => "existing_view"; end
    end
    BCell.class_eval do
      def existing_view;    @b = "b"; render :view => "existing_view"; end
    end
    assert_equal "A/existing_view/a", render_cell(:a, :existing_view)
    assert_equal "B/existing_view/b", render_cell(:b, :existing_view)
  end
  
  def test_render_passing_view_and_layout_with_locally_existing_view
    BCell.class_eval do
      def existing_view;    @b = "b"; 
        render :view => "existing_view", :layout => "metal"; end
    end
    assert_equal "Metal:B/existing_view/b", render_cell(:b, :existing_view)
  end
  
  def test_render_passing_view_and_template_format_with_locally_existing_view
    BCell.class_eval do
      def existing_view;    @b = "b"; 
        render :view => "existing_view", :template_format => :js; end
    end
    assert_equal "B/existing_view/b/js", render_cell(:b, :existing_view)
  end
  
  def test_render_passing_view_and_template_format_and_layout_with_locally_existing_view
    BCell.class_eval do
      def existing_view;    @b = "b"; 
        render :view => "existing_view", :template_format => :js, :layout => "metal"; end
    end
    assert_equal "Metal:B/existing_view/b/js", render_cell(:b, :existing_view)
  end
  
  # test :layout
  def test_render_passing_layout_located_in_cells_layout
    ACell.class_eval do
      def existing_view;    @a = "a"; 
        render :layout => "metal"; end
    end
    assert_equal "Metal:A/existing_view/a", render_cell(:a, :existing_view)
  end
  
  ### DISCUSS: currently undocumented feature:
  def test_render_passing_layout_located_in_cells_b_layouts
    BCell.class_eval do
      def existing_view;    @b = "b"; 
        render :layout => "b/layouts/metal"; end
    end
    assert_equal "B-Metal:B/existing_view/b", render_cell(:b, :existing_view)
  end
  
  # test with inherited view:
  def test_render_without_arguments_with_inherited_view
    BCell.class_eval do
      def inherited_view;   @a = "b"; render; end
    end
    assert_equal "A/inherited_view/b", render_cell(:b, :inherited_view)
  end
  
  def test_render_passing_view_with_inherited_view
    BCell.class_eval do
      def existing_view;    @a = "b"; render :view => "inherited_view"; end
    end
    assert_equal "A/inherited_view/b", render_cell(:b, :existing_view)
  end
  
  def test_render_passing_view_and_layout_with_inherited_view
    BCell.class_eval do
      def inherited_view;    @a = "b"; 
        render :view => "inherited_view", :layout => "metal"; end
    end
    assert_equal "Metal:A/inherited_view/b", render_cell(:b, :inherited_view)
  end
  
  def test_render_passing_view_and_template_format_with_inherited_view
    BCell.class_eval do
      def inherited_view;    @a = "b"; 
        render :view => "inherited_view", :template_format => :js; end
    end
    assert_equal "A/inherited_view/b/js", render_cell(:b, :inherited_view)
  end
  
  def test_render_passing_view_and_template_format_and_layout_with_inherited_view
    BCell.class_eval do
      def existing_view;    @a = "b"; 
        render :view => "inherited_view", :template_format => :js, :layout => "metal"; end
    end
    assert_equal "Metal:A/inherited_view/b/js", render_cell(:b, :existing_view)
  end
end