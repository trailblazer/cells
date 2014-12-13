module Cell
  # Gets cached in production.
  class Templates
    # prefixes could be instance variable as they will never change.
    def [](bases, prefixes, view, engine, formats=nil)
      base = bases.first # FIXME.

      find_template(base, prefixes, view, engine)
    end

  private

    def cache
      @cache ||= Cache.new
    end

    def find_template(base, prefixes, view, engine)
      view = "#{view}.#{engine}"

      cache.fetch(prefixes, view) do |prefix|
        # this block is run once per cell class per process, for each prefix/view tuple.
        create(base, prefix, view)
      end
    end

    def create(base, prefix, view)
      return unless File.exists?("#{base}/#{prefix}/#{view}") # DISCUSS: can we use Tilt.new here?
      Tilt.new("#{base}/#{prefix}/#{view}", :escape_html => false, :escape_attrs => false)
    end

    # {["comment/row/views", comment/views"][show.haml] => "Tpl:comment/view/show.haml"}
    class Cache
      def initialize
        @store = {}
      end

      # Iterates prefixes and yields block. Returns and caches when block returned template.
      # Note that it caches per prefixes set as this will most probably never change.
      def fetch(prefixes, view)
        template = get(prefixes, view) and return template # cache hit.

        prefixes.find do |prefix|
          template = yield(prefix) and return store(prefixes, view, template)
        end
      end

    private
      # ["comment/views"] => "show.haml"
      def get(prefixes, view)
        @store[prefixes] ||= {}
        @store[prefixes][view]
      end

      def store(prefix, view, template)
        @store[prefix][view] = template # the nested hash is always present here.
      end
    end
  end
end