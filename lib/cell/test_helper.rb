require 'active_support/concern'

module Cell
  module TestHelper
    extend ActiveSupport::Concern

    included do
      # Invokes assert_select for the last argument, the +content+ string.
      #
      # Example:
      #   assert_selector "h1", "The latest and greatest!", "<h1>The latest and greatest!</h1>"
      #
      # would be true.
      def assert_selector(*args, &block)
        rails_assert_select(HTML::Document.new(args.pop).root, *args, &block)
      end

      # Invokes assert_select on the markup set by the last #invoke.
      #
      # Example:
      #   invoke :latest
      #   assert_select "h1", "The latest and greatest!"
      def assert_select(*args, &block)
        super(HTML::Document.new(last_invoke).root, *args, &block)
      end

      def before_setup
        @controller ||= Class.new(ActionController::Base).new
        @request ||= ::ActionController::TestRequest.new
        @response = ::ActionController::TestResponse.new
        @controller.request = @request
        @controller.response = @response
        @controller.params = {}
      end

      # Runs the block while computing the instance variables diff from before and after.
      def extract_state_ivars_for(cell)
        before = cell.instance_variables
        yield
        after = cell.instance_variables

        Hash[(after - before).collect do |var|
               next if var =~ /^@_/
               [var[1, var.length].to_sym, cell.instance_variable_get(var)]
             end.compact]
      end


      attr_reader :last_invoke, :subject_cell, :view_assigns

      # Use this for functional tests of your application cells.
      #
      # Example:
      #   should "spit out a h1 title" do
      #     html = render_cell(:news, :latest)
      #     assert_select html, "h1", "The latest and greatest!"
      def render_cell(name, state, *args)
        # DISCUSS: should we allow passing a block here, just as in controllers?
        @subject_cell = ::Cell::Rails.cell_for(name, @controller, *args)
        @view_assigns = extract_state_ivars_for(@subject_cell) do
          @last_invoke = @subject_cell.render_state(state, *args)
        end

        @last_invoke
      end

      # Builds an instance of <tt>name</tt>Cell for unit testing.
      # Passes the optional block to <tt>cell.instance_eval</tt>.
      #
      # Example:
      #   assert_equal "Doo Dumm Dumm..." cell(:bassist).play
      def cell(name, *args, &block)
        Cell::Rails.cell_for(name, @controller, *args).tap do |cell|
          cell.instance_eval &block if block_given?
        end
      end

      # Execute the passed +block+ in a real view context of +cell_class+.
      # Usually you'd test helpers here.
      #
      # Example:
      #
      #   assert_equal("<h1>Modularity rocks.</h1>", in_view do content_tag(:h1, "Modularity rocks."))
      def in_view(cell_class, &block)
        subject = cell(cell_class)
        setup_test_states_in(subject) # add #in_view to subject cell.
        subject.render_state(:in_view, block)
      end

      protected
      def setup_test_states_in(cell)
        cell.instance_eval do
          def in_view(block=nil)
            render :inline => "<%= instance_exec(&block) %>", :locals => {:block => block}
          end
        end
      end
    end
  end
end
