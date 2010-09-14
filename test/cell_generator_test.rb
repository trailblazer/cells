require File.join(File.dirname(__FILE__), 'test_helper')

require 'rails/all'
require 'rails/generators'
require 'rails_generators/cell/cell_generator'

# Call configure to load the settings from
# Rails.application.config.generators to Rails::Generators
Rails::Generators.configure!


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
        assert_file "app/cells/blog/latest.html.erb", %r(app/cells/blog/latest\.html\.erb)

        #assert files.include?(fake_rails_root+"/test/cells/blog_cell_test.rb")
      end
      
      should "create haml assets with --haml" do
        run_generator ["Blog", "post", "latest", "--haml"]
        files = (file_list - @original_files)
        assert files.include?(fake_rails_root+"/app/cells/blog_cell.rb")
        assert files.include?(fake_rails_root+"/app/cells/blog/post.html.haml")
        assert files.include?(fake_rails_root+"/app/cells/blog/latest.html.haml")
        assert files.include?(fake_rails_root+"/test/cells/blog_cell_test.rb")
      end
    end
  end
  
  private
  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')  
  end
  
  def file_list
    Dir.glob(File.join(fake_rails_root, "**/*"))
  end 
end