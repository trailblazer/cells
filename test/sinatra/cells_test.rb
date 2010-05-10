require File.join(File.dirname(__FILE__), '/../test_helper')


class SinatraCellsTest < ActiveSupport::TestCase
  context "A sinatra cell" do
    setup do
      Cell::Base.framework = :sinatra
    end
    
    should "respond to default_template_engine" do
      
    end
  end   
end