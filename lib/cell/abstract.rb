module Cell::ViewModel::Abstract
  def self.abstract!
    @abstract = true
  end

  def self.abstract?
    @abstract
  end
end