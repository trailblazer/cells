module Cell::Util
  def util
    Inflector
  end

  class Inflector
    # copied from ActiveSupport.
    def self.underscore(constant)
      constant.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    # WARNING: this API might change.
    def self.constant_for(name)
      constant = Object
      name.split("/").each do |part|
        capitalized_part = part.split('_').collect(&:capitalize).join
        # inherit = false so only descendants are searched
        constant = constant.const_get(capitalized_part, inherit = false)
      end
      constant
    end
  end
end
