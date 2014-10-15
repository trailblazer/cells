module Cell
  # Gets cached in production.
  class Templates
    def [](bases, prefixes, view, engine, formats=nil)
      base = bases.first # FIXME.

      prefixes.find do |prefix|
        template = find_for_engines(base, prefix, view, engine) and return template
      end
    end

  private

    def cache
      @cache ||= {}
    end

    def find_for_engines(base, prefix, view, engine)
      find_template(base, prefix, view, engine)
    end

    def find_template(base, prefix, view, engine)
      cache[engine] ||= {} # the engine will probably never change as everyone uses the same tpl throughout the app.
      vcache = cache[engine][view] ||= {}

      template = vcache[prefix] and return template

      return unless File.exists?("#{base}/#{prefix}/#{view}.#{engine}") # DISCUSS: can we use Tilt.new here?

      template = Tilt.new("#{base}/#{prefix}/#{view}.#{engine}", :escape_html => false, :escape_attrs => false)

      vcache[prefix] = template
    end
  end
end