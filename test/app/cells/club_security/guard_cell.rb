class ClubSecurity::GuardCell < Cell::Base
  helper do
    def irritate; end
  end
  def help; render; end
end