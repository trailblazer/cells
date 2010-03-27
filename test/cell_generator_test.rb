require File.join(File.dirname(__FILE__), *%w[test_helper])
require 'rails_generator'
require 'rails_generator/scripts/generate'

# for some reasons the "autoloading" in Rails::Generator::Lookup doesn't work:
Rails::Generator::Base.append_sources Rails::Generator::PathSource.new(:cells, File.join(File.dirname(__FILE__)+'/../rails_generators'))

class CellGeneratorTest < Test::Unit::TestCase
  context "Running script/generate cell" do
    setup do
      FileUtils.mkdir_p(fake_rails_root)
      @original_files = file_list
    end
    
    teardown do
      FileUtils.rm_r(fake_rails_root) 
    end
    
    context "Blog post latest" do
      should "create the standard assets" do
        Rails::Generator::Scripts::Generate.new.run(%w(cell Blog post latest), :destination => fake_rails_root)
        files = (file_list - @original_files)
        assert files.include?(fake_rails_root+"/app/cells/blog_cell.rb")
        assert files.include?(fake_rails_root+"/app/cells/blog/post.html.erb")
        assert files.include?(fake_rails_root+"/app/cells/blog/latest.html.erb")
        assert files.include?(fake_rails_root+"/test/cells/blog_cell_test.rb")
      end
      
      should "create haml assets with --haml" do
        Rails::Generator::Scripts::Generate.new.run(%w(cell Blog post latest --haml), :destination => fake_rails_root)
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