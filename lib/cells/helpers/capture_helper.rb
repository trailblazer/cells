# encoding: utf-8

# Sorry for the interface violations, but it looks as if there are
# no interfaces in rails at all.
module Cells
  module Helpers
    module CaptureHelper
      # Gives you access to the outer ActionView from within your Cell view.
      #
      # See render_cell in lib/cells/rails.rb
      #
      def outer_view
        outer_view = @opts[:outer_view]
      end

      # Executes #capture on the outer ActionView and sets <tt>name</tt> as the
      # instance variable name.
      #
      # Example:
      #
      #  <p>
      #  <% outer_capture :greeting do
      #    <h1>Hi, Nick!</h1>
      #  <% end %>
      #
      # The captured markup can be accessed in your outer action view or in your layout.
      #
      #  <%= @greeting %>
      def outer_capture(name, &block)
        #outer_view = controller.parent_controller.view_context
        content     = capture(&block)
        outer_view.send(:instance_variable_set, :"@#{name}", content)
      end


      # Executes #content_for on the outer ActionView.
      #
      # Example:
      #
      #  <p>
      #  <% outer_content_for :greetings do
      #    <h1>Hi, Michal!</h1>
      #  <% end %>
      #
      # As in outer_capture, the markup can be accessed in your outer action view or in your layout.
      #
      #  <%= yield :greetings %>
      def outer_content_for(name, content = nil, &block)
        outer_view.instance_eval do
          content_for(name, content, &block)
        end

        # This was the old implementation, which didn't work for me. Also, it was needlessly complex, since we can just do an instance_eval on the outer_view and then invoke and reuse Rails' normal content_for helper.
        # The old implementation also didn't let you retrieve content with <%= content_for(:name) %> (content = nil) like the Rails one allows.
        # This was returning a different object each time outer_content_for was called -- and it certainly wasn't the same object_id as self.object_id gave from the outermost layout view, so it must be creating a new object each time or something rather than just fetching the existing one (from an instance variable, f.e.):
        #outer_view = controller.parent_controller.view_context
       #::Rails.logger.debug "...  outer_view.send(:'instance_variables')=#{ outer_view.send(:'instance_variables').inspect}"
       #::Rails.logger.debug "... outer_view.object_id=#{outer_view.object_id.inspect}"
       #content     = capture(&block) if block_given?
       #content_for = outer_view.send(:'instance_variable_get', :"@_content_for")
       #::Rails.logger.debug "... content_for=#{content_for.inspect}"
       #content_for[name] << content
       #outer_view.send(:'instance_variable_set', :"@_content_for", content_for)
       #nil
      end

      def outer_content_for?(name)
        outer_view.send("content_for?", name)
      end
    end
  end
end
