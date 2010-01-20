# encoding: utf-8

# Assertion helpers extracted from Devise by José Valim.
#
class Test::Unit::TestCase
  def setup
    @controller = ::CellsTestController.new
    @request    = ::ActionController::TestRequest.new
    @response   = ::ActionController::TestResponse.new
    @controller.request = @request
    @controller.response = @response
    @controller.params = {}
  end

  def assert_selekt(content, *args)
    assert_select(HTML::Document.new(content).root, *args)
  end

  def assert_not(assertion)
    assert !assertion
  end

  def assert_blank(assertion)
    assert assertion.blank?
  end

  def assert_not_blank(assertion)
    assert !assertion.blank?
  end
  alias :assert_present :assert_not_blank

  # Execute the block setting the given values and restoring old values after
  # the block is executed.
  #
  # == Usage/Example:
  #
  #   I18n.locale   # => :en
  #
  #   swap(I18n.locale, :se) do
        # I18n.locale   # => :se
  #   end
  #
  #   I18n.locale   # => :en
  #
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end
end
