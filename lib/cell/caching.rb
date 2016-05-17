require 'uber/options'

module Cell
  module Caching
    def self.included(includer)
      includer.class_eval do
        extend ClassMethods
        extend Uber::InheritableAttr
        inheritable_attr :version_procs
        inheritable_attr :conditional_procs
        inheritable_attr :cache_options
        inheritable_attr :used_templates

        self.version_procs = {}
        self.conditional_procs = {}
        self.cache_options = Uber::Options.new({})
        self.used_templates = {}
      end
    end

    module ClassMethods
      def cache(state, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {} # I have to admit, Array#extract_options is a brillant tool.

        if options.has_key? :used_templates
          self.used_templates[state] = Array(options.delete(:used_templates))
        end
        self.conditional_procs[state] = Uber::Options::Value.new(options.delete(:if) || true)
        self.version_procs[state] = Uber::Options::Value.new(args.first || block)
        self.cache_options[state] = Uber::Options.new(options)
      end

      # Computes the complete, namespaced cache key for +state+.
      def state_cache_key(state, key_parts={})
        expand_cache_key([controller_path, state, key_parts])
      end

      def expire_cache_key_for(key, cache_store, *args)
        cache_store.delete(key, *args)
      end

    private

      def expand_cache_key(key)
        key.join("/") # TODO: test me!
      end
    end


    def render_state(state, *args)
      state = state.to_sym
      return super(state, *args) unless cache?(state, *args)

      class_state_cache_key = self.class.state_cache_key(state, self.class.version_procs[state].evaluate(self, *args))
      key = [class_state_cache_key, digest_for(state)].join('/')
      options = self.class.cache_options.eval(state, self, *args)

      fetch_from_cache_for(key, options) { super(state, *args) }
    end

    def cache_store  # we want to use DI to set a cache store in cell/rails.
      raise "No cache store has been set."
    end

    def cache?(state, *args)
      perform_caching? and state_cached?(state) and self.class.conditional_procs[state].evaluate(self, *args)
    end

  private

    def perform_caching?
      true
    end

    def fetch_from_cache_for(key, options)
      cache_store.fetch(key, options) do
        yield
      end
    end

    def state_cached?(state)
      self.class.version_procs.has_key?(state)
    end

    def digest_for(state)
      Digest::MD5.hexdigest(dependency_digests_for(state).join('-'))
    end

    def dependency_digests_for(state)
      dependencies_for(state).map do |dep|
        file_digests[dep] ||= Digest::MD5.file(dep)
      end
    end

    # All files that this particular state depends on
    def dependencies_for(state)
      (method_files + template_files_for(state)).compact.uniq
    end

    def method_files
      relevant_methods.map do |m|
        location = method(m).source_location or next # C-bindings
        location[0]
      end
    end

    # All methods, that this Cell uses.
    # When using Rails this will also contain all helpers, that were included,
    # e.g. UrlHelpers, FormHelpers etc.
    def relevant_methods
      methods + private_methods - Cell::ViewModel.instance_methods - Cell::ViewModel.private_instance_methods
    end

    # templates, specified in `cache :show, used_templates: :template` take precedence
    # over template, implicitly derived from state
    def template_files_for(state)
      (self.class.used_templates[state] || [state]).map do |st|
        template_file_for(st)
      end
    end

    def template_file_for(state)
      options = normalize_options({view: state})
      find_template(options).file
    rescue Cell::TemplateMissingError => e
      Rails.logger.warn "Couldn't find template for digesting: #{e}"
      nil
    end

    def file_digests
      @@file_digests ||= {}
    end
  end
end
