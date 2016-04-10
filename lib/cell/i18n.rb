module Cell::I18n
  def t(*args)
    options   = args.last.is_a?(Hash) ? args.pop.dup : {}
    path = i18n_scoped_path(args.shift)
    super(path, options)
  end

  def i18n_scoped_path(key)
    concept = self.class.name.deconstantize.demodulize.underscore
    cell_name = self.class.name.demodulize.underscore

    relative_path = ['cells', concept, cell_name].reject(&:blank?).join('.')

    return "#{relative_path}#{key}" if key.starts_with?('.')
    key
  end
end
