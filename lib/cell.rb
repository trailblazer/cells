module Cell
  module OptionsConstructor
  private
    def process_args(options={})
      if options.is_a?(Hash) # TODO: i don't like this too much.
        process_options(options)
      else
        process_model(options)
      end

      super # Base.
    end

    # DISCUSS: have 2 classes for that?

    def process_options(options)
      options.each do |k, v|
        instance_variable_set("@#{k}", v)
        singleton_class.class_eval { attr_reader k }
      end
    end

    def process_model(model)
      @model = model
    end
  end
end