module Cell
  # Gets cached in production.
  class Templates
    # prefixes could be instance variable as they will never change.
    def [](prefixes, view, options)
      find_template(prefixes, view, options)
    end

  private
    def cache
      @cache ||= Tilt::Cache.new
    end

    def find_template(prefixes, view, options) # options is not considered in cache key.
      cache.fetch(prefixes, view) do
        template_prefix = prefixes.find { |prefix| File.exist?("#{prefix}/#{view}") }
        return if template_prefix.nil? # We can safely return early. Tilt::Cache does not cache nils.
        template_class = options.delete(:template_class)
        template_class.new("#{template_prefix}/#{view}", options) # Tilt.new()
      end
    end
  end
end
