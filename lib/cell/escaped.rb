module Cell::ViewModel::Escaped
  def self.included(includer)
    includer.extend Property
  end

  module Property
    def property(*names)
      names.flatten!
      super.tap do
        include Module.new {
          names.each do |name|
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{name}(escape: true)
                value = super()
                return value unless value.is_a?(String)
                return value unless escape
                escape!(value)
              end
            RUBY
          end
        }
      end
    end
  end

  # Can be used as a helper in the cell, too.
  # Feel free to override and use a different escaping implementation.
  def escape!(string)
    ::ERB::Util.html_escape(string)
  end
end
