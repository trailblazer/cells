# encoding: utf-8
module Cells
  # Assertion helpers extracted from Devise by José Valim.
  #
  module InternalAssertionsHelper
    def setup
      ### TODO: clean up CellsTestController.
      @controller = ::CellsTestController.new
      @request    = ::ActionController::TestRequest.new
      @response   = ::ActionController::TestResponse.new
      @controller.request = @request
      @controller.response = @response
      @controller.params = {}
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
    #   swap(I18n :locale => :se) do
    #     I18n.locale   # => :se
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
    
    # Provides a TestCell instance. The <tt>block</tt> is passed to instance_eval and should be used
    # to extend the mock on the fly.
    ### DISCUSS: make an anonymous subclass of TestCell?
    def cell_mock(options={}, &block)
      cell = TestCell.new(@controller, options)
      cell.instance_eval(&block) if block_given?
      cell
    end
    
    def bassist_mock(options={}, &block)
      cell = BassistCell.new(@controller, options)
      cell.instance_eval(&block) if block_given?
      cell
    end
  end
end