class ClubSecurity::GuardCell < Cell::Rails
  helper do
    def irritate; end
  end
  def help; render; end
end
