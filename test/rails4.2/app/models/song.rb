class Song < OpenStruct
  require "active_model"
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def persisted?
    true
  end

  def parents
    []
  end

  def name
    "song"
  end

  def id
    1
  end

  def artist
    Artist.new
  end
end
