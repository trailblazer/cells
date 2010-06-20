# encoding: utf-8

# Sorry for the interface violations, but it looks as if there are
# no interfaces in rails at all.
module Cells
  module Helpers
    module CaptureHelper
      # Executes #capture on the global ActionView and sets <tt>name</tt> as the
      # instance variable name.
      #
      # Example:
      #
      #  <p>
      #  <% global_capture :greeting do
      #    <h1>Hi, Nick!</h1>
      #  <% end %>
      #
      # The captured markup can be accessed in your global action view or in your layout.
      #
      #  <%= @greeting %>
      def global_capture(name, &block)
        global_view = controller.parent_controller.view_context
        content     = capture(&block)
        global_view.send(:instance_variable_set, :"@#{name}", content)
      end


      # Executes #content_for on the global ActionView.
      #
      # Example:
      #
      #  <p>
      #  <% global_content_for :greetings do
      #    <h1>Hi, Michal!</h1>
      #  <% end %>
      #
      # As in global_capture, the markup can be accessed in your global action view or in your layout.
      #
      #  <%= yield :greetings %>
      def global_content_for(name, content = nil, &block)
        # OMG. that SUCKS.
        global_view = controller.parent_controller.view_context
        ivar        = :"@content_for_#{name}"
        content     = capture(&block) if block_given?
        old_content = global_view.send(:'instance_variable_get', ivar)
        global_view.send(:'instance_variable_set', ivar, "#{old_content}#{content}")
        nil
      end
    end
  end
end
