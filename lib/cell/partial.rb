# Allows to render global partials, for example.
#
#   render partial: "../views/shared/container"
module Cell::ViewModel::Partial
  def template_for(view, engine)
    base      = self.class.view_paths
    parts     = view.split("/")
    view      = parts.pop
    view      = "_#{view}"
    prefixes  = [parts.join("/")]

    # self.class.templates[base, [parts.join("/")], "_#{view}.html", engine] or raise Cell::ViewModel::TemplateMissingError.new(base, _prefixes, view, engine, nil)
    self.class.templates[base, prefixes, view, engine] or raise Cell::TemplateMissingError.new(base, prefixes, view, engine, nil)
  end

  def process_options!(options)
    super
    options.merge!(:view => options[:partial]) if options[:partial]
    options[:view] += ".#{options[:format]}" if options[:format]
  end
end