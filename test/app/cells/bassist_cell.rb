class BassistCell < Cell::Rails
  def play
    render
  end

  def shout(args)
    @words = args[:words]
    render
  end

  def provoke
    controller.config.relative_url_root = "" if Cell.rails3_0?

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
