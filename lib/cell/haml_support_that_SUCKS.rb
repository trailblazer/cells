

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

  # TODO: remove the concept of output buffers and just return block's result!
  class OutputBuffer < String
  end


  def with_output_buffer(buf = nil)
    unless buf
      buf = OutputBuffer.new
    end
    self.output_buffer, old_buffer = buf, output_buffer
    yield
    output_buffer
  ensure
    self.output_buffer = old_buffer
  end


  # generic ERB HAML HELPERS>>>>>>
  def capture(*args,&block)
    value = nil
    buffer = with_output_buffer() { value = yield(*args) }
    if string = buffer.presence || value and string.is_a?(String)
      return string
    end
  end


  # From FormTagHelper. why do they escape every possible string? why?
  def form_tag_in_block(html_options, &block)
    content = capture(&block)
    "#{form_tag_html(html_options)}" << content << "</form>"
  end

  def form_tag_html(html_options)
    extra_tags = extra_tags_for_form(html_options)
    "#{tag(:form, html_options, true) + extra_tags}"
  end

  # Rails 4.0, TagHelper.
  def tag_option(key, value, escape)
    super(key, value, false)
  end

  def content_tag_string(name, content, options, escape=true)
    super(name, content, options, false)
  end
end
