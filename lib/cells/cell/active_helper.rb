module Cells::Cell::ActiveHelper
  
  def self.included(base)
    base.extend ClassMethods
    
    base.class_inheritable_array :active_helpers
    base.active_helpers = []
  end
  
  module ClassMethods    
    # The passed helpers will be imported in the view and thus be available in
    # your template.
    #
    # Example:
    #   class BassistCell < Cell::Base
    #     active_helper SlappingHelper
    #
    # The helper file usually resides in +app/active_helpers/+, baby.
    def active_helper(*classes)
      active_helpers.push(*classes).uniq!
    end
  end
  
  def import_active_helpers_into(view)
    return if self.class.active_helpers.blank?
    
    # We simply assume if somebody's using #active_helper, it is already
    # required.
    view.extend ::ActiveHelper
    view.use *self.class.active_helpers
  end
end
