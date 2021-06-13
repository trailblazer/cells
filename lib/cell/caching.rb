require "cell/option"

module Cell
  module Caching
    def self.included(includer)
      includer.class_eval do
        extend ClassMethods
        extend Util
        extend Uber::InheritableAttr
        inheritable_attr :version_procs
        inheritable_attr :conditional_procs
        inheritable_attr :cache_options

        self.version_procs     = {}
        self.conditional_procs = {}
        self.cache_options     = {}
      end
    end

    module ClassMethods
      def cache(state, *args, **kwargs, &block)
        conditional_procs[state] = Cell::Option(kwargs.delete(:if) || true)
        version_procs[state]     = Cell::Option(args.first || block)
        cache_options[state]     = Cell::Options(kwargs)
      end

      # Computes the complete, namespaced cache key for +state+.
      def state_cache_key(state, key_parts={})
        expand_cache_key([formatted_name, state, key_parts])
      end

      def expire_cache_key_for(key, cache_store, *args)
        cache_store.delete(key, *args)
      end

    private

      def expand_cache_key(key)
        key.join("/")
      end

      def formatted_name
        util.underscore(name)
      end
    end

    def render_state(state, *args)
      state = state.to_sym
      return super(state, *args) unless cache?(state, *args)

      key     = self.class.state_cache_key(state, self.class.version_procs[state].(*args, exec_context: self))
      options = self.class.cache_options[state].(*args, exec_context: self)

      fetch_from_cache_for(key, options) { super(state, *args) }
    end

    def cache_store  # we want to use DI to set a cache store in cell/rails.
      raise "No cache store has been set."
    end

    def cache?(state, *args)
      perform_caching? and state_cached?(state) and self.class.conditional_procs[state].(*args, exec_context: self)
    end

  private

    def perform_caching?
      true
    end

    def fetch_from_cache_for(key, options, &block)
      cache_store.fetch(key, options, &block)
    end

    def state_cached?(state)
      self.class.version_procs.has_key?(state)
    end
  end
end
