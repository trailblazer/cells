class Cell
  def self.call(private_options={}, **options)
    # raise private_options.inspect
    render(**private_options)
  end

  def self.render(template:, exec_context: nil)
    template.render(exec_context)
  end
end
