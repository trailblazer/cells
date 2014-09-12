module Cell
  # Gets cached in production.
  class Templates
    def [](bases, prefixes, view, engines, formats=nil)
      base = bases.first # FIXME.

      prefixes.find do |prefix|
        template = find_for_engines(base, prefix, view, engines) and return template
      end
    end

  private

    def cache
      @cache ||= {}
    end

    def find_for_engines(base, prefix, view, engines)
      engines.find { |engine| template = find_template(base, prefix, view, engine) and return template }
    end

    def find_template(base, prefix, view, engine)
      cache[engine] ||= {} # the engine will probably never change as everyone uses the same tpl throughout the app.
      vcache = cache[engine][view] ||= {}

      template = vcache[prefix] and return template

      puts "checking #{base}/#{prefix}/#{view}.#{engine}"

      return unless File.exists?("#{base}/#{prefix}/#{view}.#{engine}") # DISCUSS: can we use Tilt.new here?

      template = Tilt.new("#{base}/#{prefix}/#{view}.#{engine}")

      vcache[prefix] = template
    end
  end
end