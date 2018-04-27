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
        template = nil
        prefixes.find do |prefix|
          template = create(prefix, view, options)
        end
        template
      end
    end

    def create(prefix, view, options)
      # puts "...checking #{prefix}/#{view}"
      return unless File.exist?("#{prefix}/#{view}") # DISCUSS: can we use Tilt.new here?

      template_class = options.delete(:template_class)
      template_class.new("#{prefix}/#{view}", options) # Tilt.new()
    end
  end
end
