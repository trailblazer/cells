class Artist
  require "active_model"
  include ActiveModel::Conversion
  include ActiveModel::Naming

  def persisted?
    true
  end

  def parents
    []
  end

  def name
    "artist"
  end

  def id
    1
  end

  # def artist
  #   Artist.new
  # end
end
