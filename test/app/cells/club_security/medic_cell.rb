class ClubSecurity::MedicCell < Cell::Rails
  module NiceGuy
    def smile; end
  end

  helper NiceGuy
  def help; render; end
end
