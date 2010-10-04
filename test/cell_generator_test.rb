require 'test_helper'

require 'generators/cells/cell_generator'

class CellGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Cells::Generators::CellGenerator
   
  context "Running script/generate cell" do
    context "Blog post latest" do
      should "create the standard assets" do
        
        run_generator %w(Blog post latest)
        
        assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
        assert_file "app/cells/blog_cell.rb", /def post/
        assert_file "app/cells/blog_cell.rb", /def latest/
        assert_file "app/cells/blog/post.html.erb", %r(app/cells/blog/post\.html\.erb)
        assert_file "app/cells/blog/post.html.erb", %r(<p>)
        assert_file "app/cells/blog/latest.html.erb", %r(app/cells/blog/latest\.html\.erb)

        assert_file "test/cells/blog_cell_test.rb", %r(class BlogCellTest < Cell::TestCase)
      end
      
      should "create haml assets with --haml" do
        run_generator %w(Blog post latest --haml)
        
        assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
        assert_file "app/cells/blog_cell.rb", /def post/
        assert_file "app/cells/blog_cell.rb", /def latest/
        assert_file "app/cells/blog/post.html.haml", %r(app/cells/blog/post\.html\.haml)
        assert_file "app/cells/blog/post.html.haml", %r(%p)
        assert_file "app/cells/blog/latest.html.haml", %r(app/cells/blog/latest\.html\.haml)

        assert_file "test/cells/blog_cell_test.rb"
      end
      
      should "create haml assets with -t haml" do
        run_generator %w(Blog post latest -t haml)
        
        assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
        assert_file "app/cells/blog_cell.rb", /def post/
        assert_file "app/cells/blog_cell.rb", /def latest/
        assert_file "app/cells/blog/post.html.haml", %r(app/cells/blog/post\.html\.haml)
        assert_file "app/cells/blog/post.html.haml", %r(%p)
        assert_file "app/cells/blog/latest.html.haml", %r(app/cells/blog/latest\.html\.haml)

        assert_file "test/cells/blog_cell_test.rb"
      end
    end
  end
end
