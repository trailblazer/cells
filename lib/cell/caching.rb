# As always I stole a lot of code, this time from Lance Ivy <cainlevy@gmail.com> and
# his fine components plugin at http://github.com/cainlevy/components.

module Cell::Caching
  
  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
      
      alias_method_chain :render_state, :caching
    end
    
    
  end
 
 
 
  module ClassMethods  
    def cache(state, version_proc=Proc.new{})
      
    end
    
    
  end
  
  
  
  def render_state_with_caching(state)
      render_state_without_caching(state)
    end
  
    
end
