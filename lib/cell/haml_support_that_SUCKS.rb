

module WhyDoWeHaveToOverrideRailsHelpersToMakeHamlWork
    def output_buffer_with_haml
      return haml_buffer.buffer if is_haml?
      output_buffer_without_haml
    end

    def set_output_buffer_with_haml(new_buffer)
      if is_haml?
        if Haml::Util.rails_xss_safe? && new_buffer.is_a?(ActiveSupport::SafeBuffer)
          new_buffer = String.new(new_buffer)
        end
        haml_buffer.buffer = new_buffer
      else
        set_output_buffer_without_haml new_buffer
      end
    end


    def self.included(base)
      base.class_eval do
        alias_method :output_buffer_without_haml, :output_buffer
        alias_method :output_buffer, :output_buffer_with_haml

        alias_method :set_output_buffer_without_haml, :output_buffer=
        alias_method :output_buffer=, :set_output_buffer_with_haml

      end
    end

    # module Helpers
    # def capture_with_haml(*args, &block)
    #   if Haml::Helpers.block_is_haml?(block)
    #     #double assignment is to avoid warnings
    #     _hamlout = _hamlout = eval('_hamlout', block.binding) # Necessary since capture_haml checks _hamlout

    #     capture_haml(*args, &block)
    #   else
    #     capture_without_haml(*args, &block)
    #   end
    # end
    # alias_method :capture_without_haml, :capture
    # alias_method :capture, :capture_with_haml

    # def content_tag_with_haml(name, *args, &block)
    #   return content_tag_without_haml(name, *args, &block) unless is_haml?


    #   preserve = haml_buffer.options[:preserve].include?(name.to_s)

    #   if block_given? && block_is_haml?(block) && preserve
    #     return content_tag_without_haml(name, *args) {preserve(&block)}
    #   end

    #   content = content_tag_without_haml(name, *args, &block)
    #   content = Haml::Helpers.preserve(content) if preserve && content
    #   content
    # end

    # alias_method :content_tag_without_haml, :content_tag
    # alias_method :content_tag, :content_tag_with_haml

    # module HamlSupport
    #   include Haml::Helpers

    #   def haml_buffer
    #     @template_object.send :haml_buffer
    #   end

    #   def is_haml?
    #     @template_object.send :is_haml?
    #   end
    # end

    # if ActionPack::VERSION::MAJOR == 4
    #   module Tags
    #     class TextArea
    #       include HamlSupport
    #     end
    #   end
    # end

  #   class InstanceTag
  #     include HamlSupport

  #     def content_tag(*args, &block)
  #       html_tag = content_tag_with_haml(*args, &block)
  #       return html_tag unless respond_to?(:error_wrapping)
  #       return error_wrapping(html_tag) if method(:error_wrapping).arity == 1
  #       return html_tag unless object.respond_to?(:errors) && object.errors.respond_to?(:on)
  #       return error_wrapping(html_tag, object.errors.on(@method_name))
  #     end
  #   end

  #   module FormTagHelper
  #     def form_tag_with_haml(url_for_options = {}, options = {}, *parameters_for_url, &proc)
  #       if is_haml?
  #         wrap_block = block_given? && block_is_haml?(proc)
  #         if wrap_block
  #           oldproc = proc
  #           proc = haml_bind_proc do |*args|
  #             concat "\n"
  #             with_tabs(1) {oldproc.call(*args)}
  #           end
  #         end
  #         res = form_tag_without_haml(url_for_options, options, *parameters_for_url, &proc) << "\n"
  #         res << "\n" if wrap_block
  #         res
  #       else
  #         form_tag_without_haml(url_for_options, options, *parameters_for_url, &proc)
  #       end
  #     end
  #     alias_method :form_tag_without_haml, :form_tag
  #     alias_method :form_tag, :form_tag_with_haml
  #   end
end