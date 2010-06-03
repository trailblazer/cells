# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), *%w[app cells cells_test_one_cell])

module Some
  class Cell < ::Cell::Base
  end
end

class JustOneViewCell < ::Cell::Base
  def some_state
    render
  end
end

class CellContainedInPlugin < ::Cell::Base
  def some_view
  end
end

class MyTestCell < ::Cell::Base
  def direct_output
    "<h9>this state method doesn't render a template but returns a string, which is great!</h9>"
  end

  def state_with_link_to
    render
  end

  def view_in_local_test_views_dir
    render
  end

  def view_with_explicit_english_translation
    render
  end

  def view_containing_partial
    render
  end

  def view_containing_partial_without_cell_name
    render
  end

  def view_containing_nonexistant_partial
    render
  end

  def view_containing_broken_partial
    render
  end

  def view_with_instance_var
    @instance_variable_one = 'yeah'
    @instance_variable_two = 'wow'
    render
  end

  def missing_view
    render
  end

  def state_with_link_to_function
    render
  end
end

# fixtures for view inheritance -------------------------------
# views are located in cells/test/cells/my_mother_cell/
class MyMotherCell < Cell::Rails
  def hello
    @message = 'hello, kid!'
    render
  end
  def bye
    @message = 'bye, you!'
    render
  end
end

# views are located in cells/test/cells/my_child_cell/
class MyChildCell < MyMotherCell
  def hello
    @message = 'hello, mom!'
    render
  end
  # view is inherited and located in cells/test/cells/my_mother_cell/bye.html.erb
  def bye
    @message = 'bye, mom!'
    render
  end
end

module ReallyModule
  class NestedCell < ::Cell::Base
    # view: cells/test/cells/really_module/nested_cell/happy_state.html.erb
    def happy_state
      render
    end
  end
end

class CellsTest < ActionController::TestCase
  tests CellsTestController

  ### FIXME:
  # Cell::View.warn_cache_misses = true
  def setup
    super
    MyTestCell.default_template_format = :html
  end
  
  def test_view_paths
    assert_kind_of ActionView::PathSet, Cell::Base.view_paths, "must be a PathSet for proper template caching/reloading (see issue#2)"
  end
  
  def test_cells_view_paths=
    swap( Cell::Base, :view_paths => ['you', 'are', 'here'])  do
      paths = Cell::Base.view_paths
      assert_kind_of ActionView::PathSet, paths, "must not wipe out the PathSet"
      assert_equal 3, Cell::Base.view_paths.size
      assert_equal %w(you are here), Cell::Base.view_paths
    end
  end
  
  
  def test_controller_render_methods
    get :call_render_cell_with_strings  # render_cell("test", "state")
    assert_response :success
    assert_tag :tag => 'h9'

    get :call_render_cell_with_syms
    assert_response :success
    assert_tag :tag => 'h9'

    get :call_render_cell_with_state_view
    assert_select '#view_with_instance_var'
  end

 
  # test partial rendering ------------------------------------------------------

  # ok
  def test_not_existing_partial
    cell = MyTestCell.new(@controller)

    assert_raises ActionView::TemplateError do
      cell.render_state(:view_containing_nonexistant_partial)
    end
  end

  # ok
  def test_broken_partial
    cell = MyTestCell.new(@controller)

    assert_raises ActionView::TemplateError do
      cell.render_state(:view_containing_broken_partial)
    end
  end

  # ok
  def test_render_state_with_partial
    cell = MyTestCell.new(@controller)
    c = cell.render_state(:view_containing_partial)

    assert_selekt c, '#partialContained > #partial'
  end

  def test_render_state_with_partial_without_cell_name
    cell = MyTestCell.new(@controller)
    c = cell.render_state(:view_containing_partial_without_cell_name)

    assert_selekt c, '#partialContained > #partial'
  end

  

  # test Cell::View -------------------------------------------------------------

  def test_find_family_view_for_state
    cell = MyChildCell.new(@controller)
    cells_path = File.join(File.dirname(__FILE__), 'app', 'cells')
    cell_template = cell.find_family_view_for_state(:bye, ::Cells::Rails::View.new([cells_path], {}, @controller))

    assert_equal 'my_mother/bye.html.erb', cell_template.path
  end
  

  def test_defaultize_render_options_for
    cell = MyTestCell.new(@controller)

    assert_equal ({:template_format => :html, :view => :do_it}),
                  cell.defaultize_render_options_for({}, :do_it)
    assert_equal ({:template_format => :html, :view => :do_it}),
                  cell.defaultize_render_options_for({}, :do_it)
    assert_equal ({:template_format => :js, :view => :do_it}),
                  cell.defaultize_render_options_for({:template_format => :js}, :do_it)
    assert_equal ({:template_format => :html, :layout => :metal, :view => :do_it}),
                  cell.defaultize_render_options_for({:layout => :metal}, :do_it)
    assert_equal ({:template_format => :js, :layout => :metal, :view => :do_it}),
                  cell.defaultize_render_options_for({:layout => :metal, :template_format => :js}, :do_it)
  end

  # Thanks to Fran Pena who made us aware of this bug and contributed a patch.
  def test_i18n_support
    swap I18n, :locale => :en do
      cell = MyTestCell.new(@controller)
      c = cell.render_state(:view_with_explicit_english_translation)

      # the view "view_with_explicit_english_translation.en" exists, check if
      # rails' i18n found it:
      assert_selekt c, '#defaultTranslation', 0
      assert_selekt c, '#explicitEnglishTranslation'
    end
  end
  
  def test_params_in_a_cell_state
    @controller.params = {:my_param => 'value'}
    cell = TestCell.new(@controller)
    c = cell.render_state(:state_using_params)

    assert_equal 'value', c
  end
  
  def test_log
    assert_nothing_raised do
      TestCell.new(@controller).log("everything is perfect!")
    end
  end

  ### functional tests: ---------------------------------------------------------

  def test_link_to_in_view
    get :render_state_with_link_to

    assert_response :success
    assert_select 'a', 'bla'
  end
end
