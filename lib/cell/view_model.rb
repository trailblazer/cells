# no helper_method calls
# no instance variables
# no locals
# options are automatically made instance methods via constructor.
# call "helpers" in class

# TODO: warn when using ::property but not passing in model in constructor.
require 'uber/delegates'

# ViewModel is only supported in Rails +3.1. If you need it in Rails 3.0, let me know.
class Cell::ViewModel < Cell::Rails
  abstract!

  extend Uber::Delegates

  include Cell::OptionsConstructor
  #include ActionView::Helpers::UrlHelper
  include ActionView::Context # this includes CompiledTemplates, too.
  # properties :title, :body
  attr_reader :model



  module Helpers
    # DISCUSS: highest level API method. add #cell here.
    def collection(name, controller, array, method=:show)
      # FIXME: this is the problem in Concept cells, we don't wanna call Cell::Rails.cell_for here.
      array.collect { |model| cell_for(name, controller, model).call(method) }.join("\n").html_safe
    end

    # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    def cell(name, controller, *args, &block) # classic Rails fuzzy API.
      if args.first.is_a?(Hash) and array = args.first[:collection]
        return collection(name, controller, array)
      end

      cell_for(name, controller, *args, &block)
    end
  end
  extend Helpers # FIXME: do we really need ViewModel::cell/::collection ?


  class << self
    def property(*names)
      delegates :model, *names # Uber::Delegates.
    end

    include Helpers
  end

  def cell(name, *args)
    self.class.cell(name, parent_controller, *args)
  end


  def initialize(*args)
    super
    _prepare_context # happens in AV::Base at the bottom.
  end

  # render :show
  def render(options={})
    options = options_for(options, caller) # TODO: call render methods with call(:show), call(:comments) instead of directly #comments?

    super
  end

  # Invokes the passed state (defaults to :show) by using +render_state+. This will respect caching.
  # Yields +self+ (the cell instance) to an optional block.
  def call(state=:show)
    # it is ok to call to_s.html_safe here as #call is a defined rendering method.
    # DISCUSS: IN CONCEPT: render( view: implicit_state)
    content = render_state(state)
    yield self if block_given?
    content.to_s.html_safe
  end

private
  def view_context
    self
  end

  def options_for(options, caller)
    if options.is_a?(Hash)
      options.reverse_merge(:view => state_for_implicit_render(caller)) # TODO: test implicit render!
    else
      {:view => options.to_s}
    end
  end

  def state_for_implicit_render(caller)
    caller[0].match(/`(\w+)/)[1]
  end

  # def implicit_state
  #   controller_path.split("/").last
  # end


  # FIXME: this module is to fix a design flaw in Rails 4.0. the problem is that AV::UrlHelper mixes in the wrong #url_for.
  # if we could mix in everything else from the helper except for the #url_for, it would be fine.
  # FIXME: fix that in rails core.
  if Cell.rails_version.~("4.0", "4.1")
    include ActionView::Helpers::UrlHelper # gives us breaking #url_for.

    def url_for(options = nil) # from ActionDispatch:R:UrlFor.
      case options
      when nil
        _routes.url_for(url_options.symbolize_keys)
      when Hash
        _routes.url_for(options.symbolize_keys.reverse_merge!(url_options))
      when String
        options
      when Array
        polymorphic_url(options, options.extract_options!)
      else
        polymorphic_url(options)
      end
    end
    public :url_for
  else
    include ActionView::Helpers::UrlHelper
  end

end