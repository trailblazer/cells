require "trailblazer/option"
require "uber/callable"

module Cell
  # Extend `Trailblazer::Option` to make static values as callables too.
  class Option < ::Trailblazer::Option
    def self.build(value)
      callable = case value
                 when Proc, Symbol, Uber::Callable
                   value
                 else
                   ->(*) { value } # Make non-callable value to callable.
                 end

      super(callable)
    end
  end

  class Options < Hash
    # Evaluates every element and returns a hash.  Accepts arbitrary arguments.
    def call(*args, **options, &block)
      Hash[ collect { |k,v| [k,v.(*args, **options, &block) ] } ]
    end
  end

  def self.Option(value)
    ::Cell::Option.build(value)
  end

  def self.Options(options)
    Options.new.tap do |hsh|
      options.each { |k,v| hsh[k] = Option(v) }
    end
  end
end
