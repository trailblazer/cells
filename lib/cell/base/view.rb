class Cell::Base::View < ActionView::Base
  def self.prepare(modules)
    # TODO: remove for 4.0 if PR https://github.com/rails/rails/pull/6826 is merged.
    Class.new(self) do  # DISCUSS: why are we mixing that stuff into this _anonymous_ class at all? that makes things super complicated.
      include *modules.reverse
    end
  end

  def render(*args, &block)
    options = args.first.is_a?(::Hash) ? args.first : {}  # this is copied from #render by intention.

    return controller.render(*args, &block) if options[:state] or options[:view]
    super
  end
end