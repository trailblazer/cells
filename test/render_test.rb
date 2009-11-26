require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

class ACell < Cell::Base
  def existing_view
    @a = "a"; render
  end
  
  def not_existing_view
    @a = "a"; render
  end
end

class BCell < ACell
  def existing_view
    @b = "b"; render
  end
  
  def not_existing_view
    @b = "b"; render
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
      def inherited_view;   @a = "b"; render; end
    end
    assert_equal "A/inherited_view/b", render_cell(:b, :inherited_view)
  end
  
  def test_render_with_not_existing_view
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
  
  
  def test_render_passing_locals
    ACell.class_eval do
      def view_with_locals; @a = "a"; 
        render :locals => {:name => "Nick"}; end
    end
    assert_equal "A/view_with_locals/a/Nick", render_cell(:a, :view_with_locals)
  end
  
  
  def test_recursive_render_view_with_existing_view
    ACell.class_eval do
      def view_with_render_call; @a = "a"; 
        render; end
    end
    assert_equal "A/view_with_render_call/a:A/existing_view/a", render_cell(:a, :view_with_render_call)
  end
  
  def test_recursive_render_view_with_inherited_view
    BCell.class_eval do
      def view_with_render_call; @a = "b"; 
        render; end
    end
    assert_equal "B/view_with_render_call/b:A/inherited_view/b", render_cell(:b, :view_with_render_call)
  end
  
  def test_render_text
    ACell.class_eval do
      def existing_view;
        render :text => "Cells kick ass!"; end
    end
    assert_equal "Cells kick ass!", render_cell(:a, :existing_view)
  end
  
  def test_render_text_with_layout
    ACell.class_eval do
      def existing_view;
        render :text => "Cells kick ass!", :layout => 'metal'; end
    end
    assert_equal "Metal:Cells kick ass!", render_cell(:a, :existing_view)
  end
  
  def test_render_nothing
    ACell.class_eval do
      def existing_view;
        render :nothing; end
    end
    assert_equal "", render_cell(:a, :existing_view)
  end
  
  def test_render_inline
    ACell.class_eval do
      def existing_view; @a = "a"; 
        render :inline => 'A/existing_view/a:<%= a %>', :type => :erb, :locals => {:a=>'a'}; end
    end
    assert_equal "A/existing_view/a:a", render_cell(:a, :existing_view)
  end
  
  def test_render_state
    ACell.class_eval do
      def existing_view; @a = "a"; 
        render :state => :another_state
      end
      def another_state; @b = "b";
        render
      end
    end
    assert_equal "A/another_state/a,b", render_cell(:a, :existing_view)
  end
  
  def test_render_state_with_layout
    ACell.class_eval do
      def existing_view; @a = "a"; 
        render :state => :another_state, :layout => 'metal'
      end
      def another_state; @b = "b";
        render
      end
    end
    assert_equal "Metal:A/another_state/a,b", render_cell(:a, :existing_view)
  end
end