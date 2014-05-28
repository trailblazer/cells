# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class

# TODO: warn when using ::property but not passing in model in constructor.

class Cell::Rails
  module ViewModel
    include Cell::OptionsConstructor
    #include ActionView::Helpers::UrlHelper
    include ActionView::Context # this includes CompiledTemplates, too.
    # properties :title, :body
    attr_reader :model


    def self.included(*)
      ActiveSupport::Deprecation.warn("The Cell::Rails::ViewModel module is deprecated and will be removed in Cells 4.0. Please inherit: `class SongCell < Cell::ViewModel`. Thanks and don't forget to smile.")
      super
    end



    module Helpers
      # DISCUSS: highest level API method. add #cell here.
      def collection(name, controller, array, method=:show, builder=Cell::Rails)
        # FIXME: this is the problem in Concept cells, we don't wanna call Cell::Rails.cell_for here.
        array.collect { |model| builder.cell_for(name, controller, model).call(method) }.join("\n").html_safe
      end

      # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
      def cell(name, controller, *args, &block) # classic Rails fuzzy API.
        if args.first.is_a?(Hash) and array = args.first[:collection]
          return collection(name, controller, array)
        end

        Cell::Rails.cell_for(name, controller, *args, &block)
      end
    end
    extend Helpers # FIXME: do we really need ViewModel::cell/::collection ?


    module ClassMethods
      def property(*names)
        delegate *names, :to => :model
      end

      include Helpers
    end
    extend ActiveSupport::Concern


    def cell(name, *args)
      self.class.cell(name, parent_controller, *args)
    end


    def initialize(*args)
      super
      _prepare_context # happens in AV::Base at the bottom.
    end

    def render(options={})
      if options.is_a?(Hash)
        options.reverse_merge!(:view => state_for_implicit_render)
      else
        options = {:view => options.to_s}
      end

      super
    end

    def call(state=:show)
      # it is ok to call to_s.html_safe here as #call is a defined rendering method.
      # DISCUSS: IN CONCEPT: render( view: implicit_state)
      render_state(state).to_s.html_safe
    end

  private
    def view_context
      self
    end

    def state_for_implicit_render()
      caller[1].match(/`(\w+)/)[1]
    end

    # def implicit_state
    #   controller_path.split("/").last
    # end
  end


  # FIXME: this module is to fix a design flaw in Rails 4.0. the problem is that AV::UrlHelper mixes in the wrong #url_for.
  # if we could mix in everything else from the helper except for the #url_for, it would be fine.
  module LinkToHelper
    include ActionView::Helpers::TagHelper

    def link_to(name = nil, options = nil, html_options = nil, &block)
      html_options, options, name = options, name, block if block_given?
      options ||= {}

      html_options = convert_options_to_data_attributes(options, html_options)

      url = url_for(options)
      html_options['href'] ||= url

      content_tag(:a, name || url, html_options, &block)
    end

    def convert_options_to_data_attributes(options, html_options)
      if html_options
        html_options = html_options.stringify_keys
        html_options['data-remote'] = 'true' if link_to_remote_options?(options) || link_to_remote_options?(html_options)

        disable_with = html_options.delete("disable_with")
        confirm = html_options.delete('confirm')
        method  = html_options.delete('method')

        if confirm
          message = ":confirm option is deprecated and will be removed from Rails 4.1. " \
                    "Use 'data: { confirm: \'Text\' }' instead."
          ActiveSupport::Deprecation.warn message

          html_options["data-confirm"] = confirm
        end

        add_method_to_attributes!(html_options, method) if method

        if disable_with
          message = ":disable_with option is deprecated and will be removed from Rails 4.1. " \
                    "Use 'data: { disable_with: \'Text\' }' instead."
          ActiveSupport::Deprecation.warn message

          html_options["data-disable-with"] = disable_with
        end

        html_options
      else
        link_to_remote_options?(options) ? {'data-remote' => 'true'} : {}
      end
    end

    def link_to_remote_options?(options)
      if options.is_a?(Hash)
        options.delete('remote') || options.delete(:remote)
      end
    end
  end

  # FIXME: fix that in rails core.
  if Cell.rails_version.~("4.0", "4.1")
    include LinkToHelper
  else
    include ActionView::Helpers::UrlHelper
  end

end