class BassistCell < Cell::Rails
  def play
    render
  end

  def shout(args)
    @words = args[:words]
    render
  end

  def provoke
    controller.config.relative_url_root = "" if Cell.rails_version.~ 3.0

    render
  end

  def promote
    render
  end

  def slap
    @note = "D"
    render
  end
end
