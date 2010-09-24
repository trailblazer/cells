require 'test_helper'

class HooksTest < ActiveSupport::TestCase
  context "Hooks.define_hook" do
    setup do
      @klass = Class.new(Object) do
        include Hooks
        
        def executed
          @executed ||= [];
        end
      end
      
      @mum = @klass.new
      @mum.class.define_hook :after_eight
    end
    
    should "provide accessors to the stored callbacks" do
      assert_equal [], @klass._after_eight_callbacks
      @klass._after_eight_callbacks << :dine
      assert_equal [:dine], @klass._after_eight_callbacks
    end
  
    context "creates a public writer for the hook that" do
      should "accepts method names" do
        @klass.after_eight :dine
        assert_equal [:dine], @klass._after_eight_callbacks
      end
      
      should "accepts blocks" do
        @klass.after_eight do true; end
        assert @klass._after_eight_callbacks.first.kind_of? Proc
      end
    end
    
    context "Hooks.run_hook"do
      should "run without parameters" do
        @mum.instance_eval do
          def a; executed << :a; end
          def b; executed << :b; end
          
          self.class.after_eight :b
          self.class.after_eight :a
        end
        
        @mum.run_hook(:after_eight)
        
        assert_equal [:b, :a], @mum.executed
      end
      
      should "accept arbitrary parameters" do
        @mum.instance_eval do
          def a(me, arg); executed << arg+1; end
        end
        @mum.class.after_eight :a
        @mum.class.after_eight lambda { |me, arg| me.executed << arg-1 }
        
        @mum.run_hook(:after_eight, @mum, 1)
        
        assert_equal [2, 0], @mum.executed
      end
    end  
  end
end
