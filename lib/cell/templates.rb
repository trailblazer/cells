module Cell
  # Gets cached in production.
  class Templates
    def [](bases, prefixes, view, engines, formats=nil)
      base = bases.first # FIXME.
      engine = engines.first # FIXME.

      cache[engine] ||= {} # the engine will probably never change as everyone uses the same tpl throughout the app.
      vcache = cache[engine][view] ||= {}


      prefixes.find do |prefix|
        template = vcache[prefix] and return template

        puts "checking #{base}/#{prefix}/#{view}.#{engine}"

        next unless File.exists?("#{base}/#{prefix}/#{view}.#{engine}") # DISCUSS: can we use Tilt.new here?

        template = Tilt.new("#{base}/#{prefix}/#{view}.#{engine}")

        vcache[prefix] = template

        return template
      end
    end

  private

    def cache
      @cache ||= {}
    end
  end
end