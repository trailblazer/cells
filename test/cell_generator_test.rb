require 'test_helper'
require 'rails/generators/test_case'
require 'rails/generators/cell/cell_generator'

class CellGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::CellGenerator
  destination File.expand_path('../../tmp', File.dirname(__FILE__))
  setup :prepare_destination

  test 'create the standard assets' do
    run_generator %w(blog post latest  -e erb)

    assert_file 'app/cells/blog_cell.rb', /class BlogCell < Cell::ViewModel/
    assert_file 'app/cells/blog_cell.rb', /def post/
    assert_file 'app/cells/blog_cell.rb', /def latest/
    assert_file 'app/cells/blog/post.erb', %r{app/cells/blog/post\.erb}
    assert_file 'app/cells/blog/post.erb', %r{<p>}
    assert_file 'app/cells/blog/latest.erb', %r{app/cells/blog/latest\.erb}
  end

  test 'create cell that inherits from custom cell class if specified' do
    run_generator %w(Blog --parent=ApplicationCell)
    assert_file 'app/cells/blog_cell.rb', /class BlogCell < ApplicationCell/
  end

  test 'work with namespaces' do
    run_generator %w(blog/post latest  -e erb)
    assert_file 'app/cells/blog/post_cell.rb', /class Blog::PostCell < Cell::ViewModel/
    assert_file 'app/cells/blog/post_cell.rb', /def show/
    assert_file 'app/cells/blog/post_cell.rb', /def latest/
    assert_file 'app/cells/blog/post/latest.erb', %r{app/cells/blog/post/latest\.erb}
  end

  test 'work with namespaces and haml' do
    run_generator %w(blog/post latest -e haml)
    assert_file 'app/cells/blog/post_cell.rb', /class Blog::PostCell < Cell::ViewModel/
    assert_file 'app/cells/blog/post/latest.haml', %r{app/cells/blog/post/latest\.haml}
  end

  test 'work with namespaces and slim' do
    run_generator %w(blog/post latest -e slim)

    assert_file 'app/cells/blog/post_cell.rb', /class Blog::PostCell < Cell::ViewModel/
    assert_file 'app/cells/blog/post/latest.slim', %r{app/cells/blog/post/latest\.slim}
  end

  test 'create slim assets with -e slim' do
    run_generator %w(blog post latest -e slim)

    assert_file 'app/cells/blog_cell.rb', /class BlogCell < Cell::ViewModel/
    assert_file 'app/cells/blog_cell.rb', /def post/
    assert_file 'app/cells/blog_cell.rb', /def latest/
    assert_file 'app/cells/blog/post.slim', %r{app/cells/blog/post\.slim}
    assert_file 'app/cells/blog/post.slim', %r{p}
    assert_file 'app/cells/blog/latest.slim', %r{app/cells/blog/latest\.slim}
  end

  test 'create haml assets with -e haml' do
    run_generator %w(Blog post latest -e haml)

    assert_file 'app/cells/blog_cell.rb', /class BlogCell < Cell::ViewModel/
    assert_file 'app/cells/blog_cell.rb', /def post/
    assert_file 'app/cells/blog_cell.rb', /def latest/
    assert_file 'app/cells/blog/post.haml', %r{app/cells/blog/post\.haml}
    assert_file 'app/cells/blog/post.haml', %r{%p}
    assert_file 'app/cells/blog/latest.haml', %r{app/cells/blog/latest\.haml}
  end

  test 'create test_unit assets with -t test_unit' do
    run_generator %w(Blog post latest -t test_unit)

    assert_file 'test/cells/blog_cell_test.rb'
  end

  test 'work with namespace and test_unit' do
    run_generator %w(blog/post latest -t test_unit)

    assert_file 'test/cells/blog/post_cell_test.rb',  /class Blog::PostCellTest < Cell::TestCase/
  end

  test 'create test_unit assets with -t rspec' do
    run_generator %w(Blog post latest -t rspec)

    assert_no_file 'test/cells/blog_cell_test.rb'
  end

end
