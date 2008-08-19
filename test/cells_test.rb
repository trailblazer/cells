require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/testing_helper'

# this would usually happen by rails' autoloading -
# anyway, we don't test loading but rendering in this file.
require File.dirname(__FILE__) + '/cells/cells_test_one_cell'
require File.dirname(__FILE__) + '/cells/cells_test_two_cell'
require File.dirname(__FILE__) + '/cells/simple_cell'
require File.dirname(__FILE__) + '/cells/test_cell'


class MyTPLHandler
  def initialize(view)
    @view = view
  end

  def render(template, local_assigns={})
    template.source
  end
  
  # We only test whether this MyTPLHandler can render. Don't finalize i.e. compile it.
  def compilable?
    false
  end
end

ActionView::Template.register_default_template_handler("mytpl", MyTPLHandler)


module Some
  class Cell < Cell::Base
  end
end

class JustOneViewCell < Cell::Base
  def some_state
    return
  end

  def view_for_state(state)
    CellsTestMethods.views_path + "just_one_view.html.erb"
  end
end





class CellContainedInPlugin < Cell::Base
  def some_view
  end  
end


# views are located in cells/test/cells/my_test/.
class MyTestCell < Cell::Base
  def view_in_local_test_views_dir
  end
  
  def view_with_explicit_english_translation
  end
  
  def view_containing_partial
  end
  
  def view_containing_nonexistant_partial
  end
  
  def view_containing_broken_partial
  end
end

module ReallyModule
  class NestedCell < Cell::Base
    # view: cells/test/cells/really_module/nested_cell/happy_state.html.erb
    def happy_state
    end
  end
end


class CellsTest < Test::Unit::TestCase
  include CellsTestMethods
  
  # normally #possible_cell_paths points to "app/cells" or, with engines, additionally
  # to "vendor/plugins/*/app/cells".
  Cell::TemplateFinder.class_eval do
    def possible_cell_paths
      File.dirname(__FILE__) + '/cells'
    end
  end


  def test_controller_render_methods
    puts "XXX test_controller_render_methods"
    get :call_render_cell_with_strings  # render_cell("test", "state")
    assert_response :success
    assert_tag :tag => "h9"

    get :call_render_cell_with_syms
    assert_response :success
    assert_tag :tag => "h9"

    get :call_render_cell_with_state_view
    #assert_response :success
    #assert_tag :tag => "h9", :child => /^begin of view/

#    assert_tag :tag => "span", :child => /^yeah$/
    assert_select "div#RenderingView>span", /^yeah$/

    #get :render_view_with_render_cell_invocation
    #assert_response :success
    #assert_tag :tag => "h9"                       # render_cell(:test, :direct_output)
    #assert_tag :tag => "span", :child => /^yeah$/ # render_cell(:test, :rendering_state)

  end

  def test_init
    puts "XXX test_init"
    cell = TestCell.new(@controller, @my_path)

    assert cell.kind_of?(Cell::Base)
  end

  def test_render
    puts "XXX test_render"
    ###@ cell = Cell::Registry[:test].new(@controller, @path)
    cell = TestCell.new(@controller, @path)

    assert_equal cell.render_state("direct_output").class, String
    #assert_equal cell.render_state("rendering_state").class, String
    assert_raises (NoMethodError) { cell.render_state("non_existing_state") }

  end

  def test_view_for_state_overwriting
    puts "XXX test_view_for_state_overwriting"

    get :render_just_one_view_cell
    assert_response :success
    assert_tag :tag => "p", :content => "Great!"
  end

  def test_reset_bug
    puts "XXX test_reset_bug"
    get :render_reset_bug

    assert_response :success
    assert_select "p#ho", 1
  end

  def test_bug_no_1
    puts "XXX test_bug_1"
    get :render_view_with_render_cell_invocation

    ### FIXME: if this line is uncommented, we have bug #1 again:
    assert_select "span", /^yeah$/, :count => 1
    assert_select "div#AnotherRenderingView>span", "go", :count => 1

  end
  
  # test partial rendering ------------------------------------------------------
  
  def test_not_existing_partial
    t = MyTestCell.new(@controller)
    assert_raises ActionView::TemplateError do
      t.render_state(:view_containing_nonexistant_partial)
    end
  end
  
  def test_broken_partial
    t = MyTestCell.new(@controller)
    assert_raises ActionView::TemplateError do
      t.render_state(:view_containing_broken_partial)
    end
  end
  
  def test_render_partial_in_state_view
    t = MyTestCell.new(@controller)
    c = t.render_state(:view_containing_partial)
    assert_selekt c, "#partialContained>#partial"
  end
  
  
  
  # view for :instance_view is provided directly by #view_for_state.
  def test_view_for_state
    t = CellsTestOneCell.new(@controller)
    c = t.render_state(:instance_view)
    assert_selekt c, "#renamedInstanceView"
  end

  def test_state_view_existing_in_my_view_directory
    cell_one = CellsTestOneCell.new(@controller, nil)
    view_one = cell_one.render_state(:super_state)

    assert_selekt view_one, "p#superStateView", "CellsTestOneCell"
  end

  def test_state_view_existing_in_super_cell_view_directory
    puts "XXX test_state_view_existing_in_super_cell_view_directory"
    cell_two = CellsTestTwoCell.new(@controller, nil)
    view_two = cell_two.render_state(:super_state)

    assert_selekt view_two, "p#superStateView", "CellsTestTwoCell"
  end

  def test_state_view_not_existing
    cell_one = CellsTestOneCell.new(@controller, nil)
    view_one = cell_one.render_state(:state_with_no_view)

    assert_match /ATTENTION/, view_one
  end

  def test_templating_systems
    simple_cell = SimpleCell.new(@controller, nil)
    simple_view = simple_cell.render_state(:two_templates_state)

    assert_match /Written using my own spiffy templating system/, simple_view
  end

  ### API test (unit) -----------------------------------------------------------
  def test_cell_name
    puts "XXX test_cell_name"
    cell_one = CellsTestOneCell.new(@controller, nil)

    assert_equal cell_one.cell_name, "cells_test_one"
    assert_equal CellsTestOneCell.cell_name, "cells_test_one"
  end

  def test_cell_name_set_in_constructor
    puts "XXX test_cell_name_set_in_constructor"
    cell_one = CellsTestOneCell.new(@controller, "sophisticated_extra_name")

    assert_equal cell_one.cell_name, "sophisticated_extra_name"
    assert_equal CellsTestOneCell.cell_name, "cells_test_one"
  end

  def test_cell_name_suffix
    puts "XXX test_cell_name_suffix"
    assert_equal Cell::Base.name_suffix, "_cell"
  end

  def test_class_from_cell_name
    puts "XXX test_class_from_cell_name"
    assert_equal Cell::Base.class_from_cell_name("cells_test_one"), CellsTestOneCell
  end

  def test_class_autoloading
    puts "XXX test_class_autoloading"
    Dependencies.log_activity = true

    assert UnknownCell.new(@controller, nil) 


    assert_kind_of Module, ReallyModule
    assert_kind_of Class, ReallyModule::NestedCell
    #Really::NestedCell.new(@controller, nil)
  end

  def test_new_directory_hierarchy
    puts "XXX test_new_directory_hierarchy"
    cell = ReallyModule::NestedCell.new(@controller)
    view = cell.render_state(:happy_state)
    @response.body = view

    assert_select "#happyStateView"
  end

  # Thanks to Fran Pena who made us aware of this bug and contributed a patch.
  def test_gettext_support
    ### FIXME: how to set "en" as gettext's default language?
    
    t = MyTestCell.new(@controller)
    c = t.render_state(:view_with_explicit_english_translation)
    
    # the view "view_with_explicit_english_translation_en" exists, check if
    # gettext/rails found it:
    if Object.const_defined?(:GetText)
      assert_selekt c, "#defaultTranslation", 0
      assert_selekt c, "#explicitEnglishTranslation"
    else
      assert_selekt c, "#defaultTranslation"
    end
  end
  
  
  def test_modified_view_finding_for_testing
    
    
    t = MyTestCell.new(@controller)
    c = t.render_state(:view_in_local_test_views_dir)
    assert_selekt c, "#localView"
  end
  
  ### functional tests: ---------------------------------------------------------

  def test_link_to_in_view
    puts "XXX test_link_to_in_view"
    get :render_state_with_link_to

    assert_response :success
    assert_select "a", "bla"
  end

  def ERROR_test_link_to_in_view
    puts "XXX ERROR_test_link_to_in_view"
    @controller.params = {}
    @controller.send :initialize_current_url

    cell = TestCell.new(@controller, nil)
    content = cell.render_state(:state_with_link_to)
    assert_select HTML::Document.new(content).root, "div#linkTo"
  end

end
