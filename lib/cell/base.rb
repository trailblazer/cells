require 'abstract_controller'
require 'cell/builder'
require 'cell/caching'
require 'cell/rendering'
require 'cell/dsl'

module Cell
  module RailsVersion
    def rails3_0?
      ::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR == 0
    end

    def rails3_1_or_more?
      (::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 1)
    end

    def rails3_2_or_more?
      (::ActionPack::VERSION::MAJOR == 3 and ::ActionPack::VERSION::MINOR >= 2)
    end

    def rails4_0?
      ::ActionPack::VERSION::MAJOR == 4 and ::ActionPack::VERSION::MINOR == 0
    end

    def rails4_1_or_more?
      (::ActionPack::VERSION::MAJOR == 4 and ::ActionPack::VERSION::MINOR >= 1) or ::ActionPack::VERSION::MAJOR > 4
    end
    alias_method :rails4_1?, :rails4_1_or_more?
  end
  extend RailsVersion


  class Base < AbstractController::Base
    # TODO: deprecate Base in favour of Cell.

    abstract!
    DEFAULT_VIEW_PATHS = [File.join('app', 'cells')]

    include AbstractController
    include AbstractController::Rendering, Helpers, Callbacks, Translation, Logger

    require 'cell/rails3_0_strategy' if Cell.rails3_0?
    require 'cell/rails3_1_strategy' if Cell.rails3_1_or_more?
    require 'cell/rails4_0_strategy' if Cell.rails4_0?
    require 'cell/rails4_1_strategy' if Cell.rails4_1_or_more?
    include VersionStrategy
    include Layouts
    include Rendering
    include Caching
    include Cell::DSL

    extend Builder::ClassMethods # ::build DSL method and ::builders.


    def initialize(*args)
      super() # AbC::Base.
      process_args(*args)
    end


    class Builder < Cell::Builder
      def initialize(name, exec_context)
        constant = class_from_cell_name(name)
        super(constant, exec_context)
      end

      # Infers the cell name, old style, where cells were named CommentCell.
      def class_from_cell_name(name)
        "#{name}_cell".classify.constantize
      end
    end


    class << self
      # Main entry point for instantiating cells.
      def cell_for(name, *args)
        Builder.new(name, self).cell_for(*args)
      end

      alias_method :create_cell_for, :cell_for # TODO: remove us in 3.12.
      ActiveSupport::Deprecation.deprecate_methods(self, :create_cell_for => :cell_for)
    end

  private
    def process_args(*)
    end

    class View < ActionView::Base
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


    def self.view_context_class
      @view_context_class ||= begin
        Cell::Base::View.prepare(helper_modules)
      end
    end

    # Called in Railtie at initialization time.
    def self.setup_view_paths!
      self.view_paths = self::DEFAULT_VIEW_PATHS
    end

    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end


    # Enforces the new trailblazer directory layout where cells (or concepts in general) are fully self-contained in its own directory.
    module SelfContained
      def self_contained!
        include Prefixes
      end

      module Prefixes
        # TODO: fix that in rails core. parent_prefixes should simply call parent_controller._prefixes.
        def _prefixes
         @_prefixes ||= begin
            super.tap do |prefixes|
              prefixes.each_with_index do |prefix, i|
                prefixes[i] = "#{prefixes[i]}/views" # FIXME: why isn't this properly done in Rails core? _prefixes should return "prefix/views" from parent.
              end
            end
         end
        end
      end
    end
    extend SelfContained
  end
end
