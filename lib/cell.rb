require "tilt/template"

class Cell
  def self.call(private_options={}, **options, &block)
    # raise private_options.inspect
    render(**private_options, &block)
  end

  def self.render(template:, exec_context: nil, &block)
    template.render(exec_context, &block)
  end
end
