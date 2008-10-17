# To improve performance rendered state views can be cached using Rails' caching
# mechanism.
# If this it configured (e.g. using our fast friend memcached) all you have to do is to 
# tell Cells which state you want to cache. You can further attach a proc for deciding
# versions or to instruct re-rendering.
#
# As always I stole a lot of code, this time from Lance Ivy <cainlevy@gmail.com> and
# his fine components plugin at http://github.com/cainlevy/components.

module Cell::Caching
  
  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
      
      alias_method_chain :render_state, :caching
      
      cattr_accessor :version_procs
      base.version_procs= {}  ### DISCUSS: what about per-instance caching definitions?
    end
    
    
  end
 
 
 
  module ClassMethods
    # Activate caching for the state <tt>state</tt>. If <tt>version_proc</tt> is omitted,
    # the view will be cached forever.
    # Otherwise you may either directly pass a Proc or provide a Symbol,
    # which is treated as an instance method of the cell.
    # This method is called every time the state is rendered, and is expected to return a
    # Hash containing the cache key ingredients.
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
    #--
    ### TODO: implement for string, nil.
    ### DISCUSS: introduce return method #sweep ? so the Proc can explicitly
    ###   delegate re-rendering to the outside.
    #--
    def cache(state, version_proc = Proc.new{Hash.new})
      #return unless ActionController::Base.cache_configured?
      version_procs[state] = version_proc
    end
    
    def cache_store #:nodoc:
      @cache_store ||= ActionController::Base.cache_store
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
    return write_fragment(key, render_state_without_caching(state))
  end
  
  
  def read_fragment(key, cache_options = nil) #:nodoc:
    returning self.class.cache_store.read(key, cache_options) do |content|
      @controller.logger.debug "Cell Cache hit: #{key}" unless content.blank?
    end
  end
 
  def write_fragment(key, content, cache_options = nil) #:nodoc:
    @controller.logger.debug "Cell Cache miss: #{key}"
    self.class.cache_store.write(key, content, cache_options)
    content
  end
  
  
  def state_cached?(state);           version_proc_for_state(state);  end
  def version_proc_for_state(state);  self.class.version_procs[state];  end
  
  
  # Call the versioning Proc for the respective state.
  def call_version_proc_for_state(state)
    version_proc = version_proc_for_state(state)
    return unless version_proc  ### DISCUSS: what to do if there's simply nothing?
    
    return version_proc.call(self) if version_proc.kind_of? Proc
    send(version_proc)
  end
  
  
  def cache_key(state, args = {}) #:nodoc:
    key_pieces = [self.class, state]
        
    args.collect{|a,b| [a.to_s, b]}.sort.each{ |k,v| key_pieces << "#{k}=#{v}" }
    key = key_pieces.join('/')
 
    ActiveSupport::Cache.expand_cache_key(key, :cells)
  end
  
  
  
  
end
