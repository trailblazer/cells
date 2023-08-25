require "tilt/template"

class Cell

  def self.call(private_options={}, **options, &block)
    html = render_template(**private_options, &block)

    exec_context = private_options[:exec_context] # DISCUSS: swap positional and kw?

    # DISCUSS: make this optional?
    Result.new(
      content: html,
      **exec_context.to_h,
    ).freeze
  end

  class Result
    def initialize(content:, **options)
      @content = content
      @options = options
    end

    def to_s
      @content
    end

    def to_h
      @options
    end
  end

  # Tilt-specific
  def self.render_template(template:, exec_context: nil, &block)
    template.render(exec_context, &block)
  end
end





# def self.call(template:, exec_context:)
#   # html = super
#   # DISCUSS: do we need exec_context.() ? yes, to dispatch to different views, maybe?
#   _result = exec_context.(template: template) # returns {Result}.
# end

# def call(template:, &block)
#   html = ::Cell.render(template: template, exec_context: self, &block)

#   # DISCUSS: make this optional?
#   ::Cell::Result.new(
#     content: html,
#     **to_h,
#   ).freeze
# end
