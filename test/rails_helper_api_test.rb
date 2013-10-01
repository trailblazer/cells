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
      skip unless Cell.rails3_1_or_more? and Rails::VERSION::MINOR == 2

      form = BassistCell.new.render_state(:edit)
      form.must_match /<form accept-charset="UTF-8" action="\/fruits"/
      form.must_match /name="fruit\[title\]"/
    end
  end
end
