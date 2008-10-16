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
    # Proc must return a Hash, a String or nil, which is appended to the cell cache key.
    #
    # Example:
    #   class CachingCell < Cell::Base
    #     cache :versioned_cached_state, Proc.new{ {:version => 0} }
    # would result in the complete cache key
    #   cells/CachingCell/versioned_cached_state/version=0
    #--
    ### TODO: implement for string and nil.
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
    ### DISCUSS: see sweep discussion at #call_version_proc_for_state.
    
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
    version_proc.call(self) if version_proc
  end
  
  def cache_key(state, args = {}) #:nodoc:
    key_pieces = [self.class, state]
    args.sort.each{ |k,v| key_pieces << "#{k}=#{v}" } ### TODO: url_encode, escape, whatever.
    
    key = key_pieces.collect { |arg| arg.to_param }.join('/')
 
    ActiveSupport::Cache.expand_cache_key(key, :cells)
  end
  
  
  
end
