module Cell::I18n

  def t(*args)
    options   = args.last.is_a?(Hash) ? args.pop.dup : {}
    key       = args.shift
    cell_name = self.class.to_s.delete('Cell').underscore

    path = if key.starts_with?('.')
      "cells.#{cell_name}#{key}"
    else
      key
    end

    super(path, options)
  end
end