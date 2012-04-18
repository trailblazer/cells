require 'test_helper'
require 'generators/rails/cell_generator'

class CellGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Rails::Generators::CellGenerator

  context "CellGenerator" do
    should "create the standard assets" do
      run_generator %w(Blog post latest)

      assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
      assert_file "app/cells/blog_cell.rb", /def post/
      assert_file "app/cells/blog_cell.rb", /def latest/
      assert_file "app/cells/blog/post.html.erb", %r(app/cells/blog/post\.html\.erb)
      assert_file "app/cells/blog/post.html.erb", %r(<p>)
      assert_file "app/cells/blog/latest.html.erb", %r(app/cells/blog/latest\.html\.erb)


      assert_no_file "app/cells/blog/post.html.haml"
      assert_no_file "app/cells/blog/post.html.haml"
      assert_no_file "app/cells/blog/latest.html.haml"

      assert_no_file "app/cells/blog/post.html.slim"
      assert_no_file "app/cells/blog/post.html.slim"
      assert_no_file "app/cells/blog/latest.html.slim"
    end

    should "create cell that inherits from custom cell class if specified" do
      run_generator %w(Blog --base-cell-class=ApplicationCell)
      assert_file "app/cells/blog_cell.rb", /class BlogCell < ApplicationCell/
    end
    
    should "work with namespaces" do
      run_generator %w(Blog::Post latest)

      assert_file "app/cells/blog/post_cell.rb", /class Blog::PostCell < Cell::Rails/
      assert_file "app/cells/blog/post_cell.rb", /def latest/
      assert_file "app/cells/blog/post/latest.html.erb", %r(app/cells/blog/post/latest\.html\.erb)
    end
    
    should "work with namespaces and haml" do
      run_generator %w(Blog::Post latest -e haml)

      assert_file "app/cells/blog/post_cell.rb", /class Blog::PostCell < Cell::Rails/
      assert_file "app/cells/blog/post/latest.html.haml", %r(app/cells/blog/post/latest\.html\.haml)
    end

    should "work with namespaces and slim" do
      run_generator %w(Blog::Post latest -e slim)

      assert_file "app/cells/blog/post_cell.rb", /class Blog::PostCell < Cell::Rails/
      assert_file "app/cells/blog/post/latest.html.slim", %r(app/cells/blog/post/latest\.html\.slim)
    end

    should "create slim assets with -e slim" do
      run_generator %w(Blog post latest -e slim)

      assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
      assert_file "app/cells/blog_cell.rb", /def post/
      assert_file "app/cells/blog_cell.rb", /def latest/
      assert_file "app/cells/blog/post.html.slim", %r(app/cells/blog/post\.html\.slim)
      assert_file "app/cells/blog/post.html.slim", %r(p)
      assert_file "app/cells/blog/latest.html.slim", %r(app/cells/blog/latest\.html\.slim)


      assert_no_file "app/cells/blog/post.html.erb"
      assert_no_file "app/cells/blog/post.html.erb"
      assert_no_file "app/cells/blog/latest.html.erb"

      assert_no_file "app/cells/blog/post.html.haml"
      assert_no_file "app/cells/blog/post.html.haml"
      assert_no_file "app/cells/blog/latest.html.haml"
    end

    should "create haml assets with -e haml" do
      run_generator %w(Blog post latest -e haml)

      assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
      assert_file "app/cells/blog_cell.rb", /def post/
      assert_file "app/cells/blog_cell.rb", /def latest/
      assert_file "app/cells/blog/post.html.haml", %r(app/cells/blog/post\.html\.haml)
      assert_file "app/cells/blog/post.html.haml", %r(%p)
      assert_file "app/cells/blog/latest.html.haml", %r(app/cells/blog/latest\.html\.haml)


      assert_no_file "app/cells/blog/post.html.erb"
      assert_no_file "app/cells/blog/post.html.erb"
      assert_no_file "app/cells/blog/latest.html.erb"

      assert_no_file "app/cells/blog/post.html.slim"
      assert_no_file "app/cells/blog/post.html.slim"
      assert_no_file "app/cells/blog/latest.html.slim"
    end

    should "create test_unit assets with -t test_unit" do
      run_generator %w(Blog post latest -t test_unit)

      assert_file "test/cells/blog_cell_test.rb"
    end

    should "create test_unit assets with -t rspec" do
      run_generator %w(Blog post latest -t rspec)

      assert_no_file "test/cells/blog_cell_test.rb"
    end
  end
end
