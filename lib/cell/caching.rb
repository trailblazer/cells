require 'active_support/concern'
require 'active_support/cache'
require 'uber/options'
require 'uber/inheritable_attr'

module Cell
  module Caching
    extend ActiveSupport::Concern

    included do
      extend Uber::InheritableAttr
      inheritable_attr :version_procs
      inheritable_attr :conditional_procs
      inheritable_attr :cache_options

      self.version_procs = {}
      self.conditional_procs = {}
      self.cache_options = Uber::Options.new({})
    end

    module ClassMethods
      def cache(state, *args, &block)
        options = args.extract_options!

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
        ::ActiveSupport::Cache.expand_cache_key(key, :cells)
      end
    end


    def render_state(state, *args)
      return super(state, *args) unless cache?(state, *args)

      key     = self.class.state_cache_key(state, self.class.version_procs[state].evaluate(self, *args))
      options = self.class.cache_options.eval(state, self, *args)

      fetch_from_cache_for(key, options) { super(state, *args) }
    end

    def cache_configured?
      @cache_configured
    end
    attr_writer :cache_configured

    attr_accessor :cache_store  # we want to use DI to set a cache store in cell/rails.

    def cache?(state, *args)
      cache_configured? and state_cached?(state) and self.class.conditional_procs[state].evaluate(self, *args)
    end

  private
    def fetch_from_cache_for(key, options)
      cache_store.fetch(key, options) do
        yield
      end
    end

    def state_cached?(state)
      self.class.version_procs.has_key?(state)
    end


    module Notifications
      def fetch_from_cache_for(key, options)
        ActiveSupport::Notifications.instrument("read_fragment.action_controller", :key => key) do
          cache_store.fetch(key, options) do
            ActiveSupport::Notifications.instrument("write_fragment.action_controller", :key => key) do
              yield
            end
          end
        end
      end
    end
  end # Caching
end
