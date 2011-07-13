class ClubSecurity::MedicCell < Cell::Base
  module NiceGuy
    def smile; end
  end

  helper NiceGuy
  def help; render; end
end