class BassistCell < Cell::Base
  def play; render; end

  def shout(args)
    @words = args[:words]
    render
  end
end
