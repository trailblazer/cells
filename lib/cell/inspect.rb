module Cell
  module Inspect
    def inspect
      if inspect_blacklist.any?
        build_inspect_s
      else
        super
      end
    end

    private

    def build_inspect_s
      ivars = Hash[self.instance_variables.map { |name| [name[1..-1], self.instance_variable_get(name)] }]

      ivars_s = ivars.map do |name, value|
        if inspect_blacklist.include?(name)
          "@#{name}=#<#{value.class.name}:#{value.object_id}>"
        else
          "<@#{name}=#{value.inspect}>"
        end
      end.join(', ')

      "#<#{self.class.name}:#{self.object_id} #{ivars_s}>"
    end

    def inspect_blacklist
      []
    end
  end
end
