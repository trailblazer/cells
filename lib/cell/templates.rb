module Cell
  # Gets cached in production.
  class Templates
    def [](bases, prefixes, view, engines, formats=nil)
      base = bases.first # FIXME.
      engine = engines.first # FIXME.

      prefixes.find do |prefix|
        puts "checking #{base}/#{prefix}/#{view}.#{engine}"

        next unless File.exists?("#{base}/#{prefix}/#{view}.#{engine}") # DISCUSS: can we use Tilt.new here?
        return Tilt.new("#{base}/#{prefix}/#{view}.#{engine}")
      end
    end
  end
end