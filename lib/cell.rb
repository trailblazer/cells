module Cell
  module OptionsConstructor
    def process_args(options={})
      options.each do |k, v|
        instance_variable_set("@#{k}", v)
        singleton_class.class_eval { attr_reader k }
      end

      super # Base.
    end
  end
end