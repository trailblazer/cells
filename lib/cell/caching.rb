require 'active_support/concern'
require 'active_support/cache'

module Cell
  module Caching
    extend ActiveSupport::Concern

    module ClassMethods
      # Activate caching for the state <tt>state</tt>. If no other options are passed
      # the view will be cached forever.
      #
      # You may pass a Proc or a Symbol as cache expiration <tt>version_proc</tt>.
      # This method is called every time the state is rendered, and is expected to return a
      # Hash containing the cache key ingredients.
      #
      # Additional options will be passed directly to the cache store when caching the state.
      # Useful for simply setting a TTL for a cached state.
      # Note that you may omit the <tt>version_proc</tt>.
      #
      #
      # Example:
      #   class CachingCell < ::Cell::Base
      #     cache :versioned_cached_state, Proc.new{ {:version => 0} }
      # would result in the complete cache key
      #   cells/CachingCell/versioned_cached_state/version=0
      #
      # If you provide a symbol, you can access the cell instance directly in the versioning
      # method:
      #
      #   class CachingCell < ::Cell::Base
      #     cache :cached_state, :my_cache_version
      #
      #     def my_cache_version
      #       { :user     => current_user.id,
      #         :item_id  => params[:item] }
      #       }
      #     end
      # results in a very specific cache key, for customized caching:
      #   cells/CachingCell/cached_state/user=18/item_id=1
      #
      # You may also set a TTL only, e.g. when using the memcached store:
      #
      #  cache :cached_state, :expires_in => 3.minutes
      #
      # Or use both, having a versioning proc <em>and</em> a TTL expiring the state as a fallback
      # after a certain amount of time.
      #
      #  cache :cached_state, Proc.new { {:version => 0} }, :expires_in => 10.minutes
      #--
      ### TODO: implement for string, nil.
      ### DISCUSS: introduce return method #sweep ? so the Proc can explicitly
      ###   delegate re-rendering to the outside.
      #--
      def cache(state, version_proc=nil, cache_opts={})
        if version_proc.is_a?(Hash)
          cache_opts    = version_proc
          version_proc  = nil
        end

        version_procs[state]  = version_proc
        cache_options[state]  = cache_opts
      end

      def version_procs
        @version_procs ||= {}
      end

      def cache_options
        @cache_options ||= {}
      end

      def cache_store
        # DISCUSS: move to instance level and delegate to #config/#parent_controller.
        # This would allow convenient cache settings per cell (if needed).
        ::ActionController::Base.cache_store
      end
      
      # Computes the complete, namespaced cache key for +state+.
      def state_cache_key(state, key_parts={})
        expand_cache_key([cell_name, state, key_parts])
      end

      def expire_cache_key(key, *args)
        cache_store.delete(key, *args)
      end
      
      def cache?(state)
        # DISCUSS: why is it private?
        ActionController::Base.send(:cache_configured?) and state_cached?(state)
      end
      
    protected
      # Compiles cache key and adds :cells namespace to +key+, according to the
      # ActiveSupport::Cache.expand_cache_key API.
      def expand_cache_key(key)
        ::ActiveSupport::Cache.expand_cache_key(key, :cells)
      end
      
      def state_cached?(state)
        version_procs.has_key?(state)
      end
    end

    def render_state(state, *args)
      return super(state, *args) unless self.class.cache?(state)
      
      key     = self.class.state_cache_key(state, call_version_proc_for_state(state))
      options = self.class.cache_options[state]
      
      self.class.cache_store.fetch(key, options) do
        super(state, *args)
      end
    end

    # Call the versioning Proc for the respective state.
    def call_version_proc_for_state(state)
      version_proc = self.class.version_procs[state]

      return {} unless version_proc # call to #cache was without any args.

      return version_proc.call(self) if version_proc.kind_of?(Proc)
      send(version_proc)
    end
    
  end
end
