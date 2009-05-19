# To improve performance rendered state views can be cached using Rails' caching
# mechanism.
# If this it configured (e.g. using our fast friend memcached) all you have to do is to 
# tell Cells which state you want to cache. You can further attach a proc to expire the 
# cached view.
#
# As always I stole a lot of code, this time from Lance Ivy <cainlevy@gmail.com> and
# his fine components plugin at http://github.com/cainlevy/components.

module Cell::Caching
  
  def self.included(base) #:nodoc:
    base.class_eval do
      # mixin Cell::Base#cache, setup vars and extend #render_state if caching's on.
      extend ClassMethods
      
      return unless ActionController::Base.cache_configured?
      
      alias_method_chain :render_state, :caching
    end
    
    
  end
 
 
 
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
    #   class CachingCell < Cell::Base
    #     cache :versioned_cached_state, Proc.new{ {:version => 0} }
    # would result in the complete cache key
    #   cells/CachingCell/versioned_cached_state/version=0
    #
    # If you provide a symbol, you can access the cell instance directly in the versioning
    # method:
    #
    #   class CachingCell < Cell::Base
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
    
    def version_procs;  @version_procs    ||= {}; end
    def cache_options;  @cache_options    ||= {}; end
    
    def cache_store #:nodoc:
      @cache_store ||= ActionController::Base.cache_store
    end
    
    def cache_key_for(cell_class, state, args = {}) #:nodoc:
      key_pieces = [cell_class, state]

      args.collect{|a,b| [a.to_s, b]}.sort.each{ |k,v| key_pieces << "#{k}=#{v}" }
      key = key_pieces.join('/')

      ActiveSupport::Cache.expand_cache_key(key, :cells)
    end
    
    def expire_cache_key(key, opts=nil)
      cache_store.delete(key, opts)
    end
  end
  
  
  
  def render_state_with_caching(state)
    return render_state_without_caching(state) unless state_cached?(state) 
    
    key = cache_key(state, call_version_proc_for_state(state))
    ### DISCUSS: see sweep discussion at #cache.
    
    # cache hit:
    if content = read_fragment(key)
      return content 
    end
    # re-render:
    return write_fragment(key, render_state_without_caching(state), cache_options[state])
  end
  
  
  def read_fragment(key, cache_options = nil) #:nodoc:
    returning self.class.cache_store.read(key, cache_options) do |content|
      @controller.logger.debug "Cell Cache hit: #{key}" unless content.blank?
    end
  end
 
  def write_fragment(key, content, cache_opts = nil) #:nodoc:
    @controller.logger.debug "Cell Cache miss: #{key}"
    self.class.cache_store.write(key, content, cache_opts)
    content
  end
  
  # Call the versioning Proc for the respective state.
  def call_version_proc_for_state(state)
    version_proc = version_procs[state]
    
    return {} unless version_proc # call to #cache was without any args.
    
    return version_proc.call(self) if version_proc.kind_of? Proc
    send(version_proc)
  end
  
  def cache_key(state, args = {}) #:nodoc:
    self.class.cache_key_for(self.cell_name, state, args)
  end
  
  def state_cached?(state); self.class.version_procs.has_key?(state);  end
  def version_procs;        self.class.version_procs;  end
  def cache_options;        self.class.cache_options;  end

end