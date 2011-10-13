require 'active_support/concern'
require 'active_support/cache'

module Cell
  module Caching
    extend ActiveSupport::Concern

    included do
      class_attribute :version_procs, :conditional_procs, :cache_options
      self.version_procs = {}
      self.conditional_procs = {}
      self.cache_options = {}
    end

    module ClassMethods
      # Caches the rendered view of +state+.
      #
      # Examples:
      #
      # This will cache forever.
      #
      #   class CartCell < Cell::Base
      #     cache :show
      #
      # You can also pass options to the caching engine as known from Rails caching.
      #
      #   cache :show, :expires_in => 10.minutes
      #
      # The +:if+ option lets you define a conditional proc or instance method. If it doesn't
      # return a true value, caching for that state is skipped.
      #
      #   cache :show, :if => proc { |cell, options| options[:enable_cache] }
      #
      # If you need your own granular cache keys, pass a versioner block.
      #
      #   cache :show do |cell, options|
      #     "user/#{cell.options[:id]}"
      #   end
      #
      # This will result in a cache key like <tt>cells/cart/show/user/1</tt>.
      #
      # Alternatively, use an instance method.
      #
      #   cache :show, :versioner
      #   def versioner(options)
      #     "user/#{options[:id]}"
      #   end
      #
      # Two things to mention here.
      # * The return value of the method/block is <em>appended</em> to the state cache key.
      # * You may return a string, a hash, an array, ActiveSupport::Caching will compile it.
      #
      # == Inheritance
      # Please note that cache configuration is inherited to derived cells.
      def cache(state, *args, &block)
        options = args.extract_options!

        self.conditional_procs = conditional_procs.merge(state => options.delete(:if))
        self.version_procs     = version_procs.merge(state => (args.first || block))
        self.cache_options     = cache_options.merge(state => options)
      end

      def cache_store
        # DISCUSS: move to instance level and delegate to #config/#parent_controller.
        # This would allow convenient cache settings per cell (if needed).
        ::ActionController::Base.cache_store
      end
      
      # Computes the complete, namespaced cache key for +state+.
      def state_cache_key(state, key_parts={})
        expand_cache_key([controller_path, state, key_parts])
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
      return super(state, *args) unless cache?(state, *args)
      
      key     = self.class.state_cache_key(state, call_state_versioner(state, *args))
      options = self.class.cache_options[state]
      
      self.class.cache_store.fetch(key, options) do
        super(state, *args)
      end
    end
    
    def cache?(state, *args)
      self.class.cache?(state) and call_state_conditional(state, *args)
    end
    
  protected
    def call_proc_or_method(state, method, *args)
      return method.call(self, *args) if method.kind_of?(Proc)
      send(method, *args)
    end
    
    def call_state_versioner(state, *args)
      method = self.class.version_procs[state] or return
      call_proc_or_method(state, method, *args)
    end
    
    def call_state_conditional(state, *args)
      method = self.class.conditional_procs[state] or return true
      call_proc_or_method(state, method, *args)
    end
    
  end
end
