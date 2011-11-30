class BassistCell < Cell::Rails
  def play; render; end

  def shout(args)
    @words = args[:words]
    render
  end
end
