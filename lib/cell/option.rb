require "trailblazer/option"
require "uber/callable"

# DISCUSS: Should we move this to trb-option instead ?
# This is identical to `Representable::Option`.
module Cell
  # Extend `Trailblazer::Option` to support static values as callables too.
  class Option < ::Trailblazer::Option
    def self.callable?(value)
      [Proc, Symbol, Uber::Callable].any?{ |kind| value.is_a?(kind) }
    end

    def self.build(value)
      return ->(*) { value } unless callable?(value) # Wrap static `value` into a proc. 
      super
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
