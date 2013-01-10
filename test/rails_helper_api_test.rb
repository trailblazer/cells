require 'test_helper'
require 'cell/rails/helper_api'


class RailsHelperAPITest < MiniTest::Spec
  class ::Fruit
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    def initialize(attributes={})
      @attributes = attributes
    end
    
    def title
      @attributes[:title]
    end
    
    def persisted?
      false
    end
  end


  class FakeUrlFor # it be sinatra's url helper instance
    def url_for(*)
    end
  end

  module FakeHelpers
    def fruits_path(model, *args)
      "/fruits"
    end
  end

  require "simple_form"
  class BassistCell < Cell::Base
    include Cell::Rails::HelperAPI
    
    self._helpers = FakeHelpers
    self._routes = FakeUrlFor.new
    
    def edit
      @tone = "C"
      @fruit = Fruit.new(:title => "Banana")
      render
    end
  end
  
  describe "Rails::HelperAPI" do
    it "allows accessing the request object" do
      #BassistCell.append_view_path(".")
      assert_equal '<form accept-charset="UTF-8" action="/fruits" class="simple_form new_fruit" id="new_fruit" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
	<div class="input string required"><label class="string required" for="fruit_title"><abbr title="required">*</abbr> Title</label><input class="string required" id="fruit_title" name="fruit[title]" required="required" size="50" type="text" value="Banana" /></div>
	<input class="button" name="commit" type="submit" value="Create Fruit" />
</form>
', BassistCell.new.render_state(:edit) if Cell.rails3_1_or_more? and Rails::VERSION::MINOR == 2
    end
  end
end
