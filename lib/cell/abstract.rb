module Cell::Abstract
  def abstract!
    @abstract = true
  end

  def abstract?
    @abstract if defined?(@abstract)
  end
end