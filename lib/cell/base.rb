require 'abstract_controller'
require 'cell/builder'
require 'cell/caching'
require 'cell/rendering'
require 'cell/dsl'

module Cell
  require 'uber/version'
  def self.rails_version
    Uber::Version.new(::ActionPack::VERSION::STRING)
  end


  class Base < AbstractController::Base
    # TODO: deprecate Base in favour of Cell.
    abstract!

    include AbstractController
    include AbstractController::Rendering, Helpers, Callbacks, Translation, Logger

    self.view_paths = "app/cells"


    require 'cell/rails3_0_strategy' if Cell.rails_version.~  "3.0"
    require 'cell/rails3_1_strategy' if Cell.rails_version.~( "3.1", "3.2")
    require 'cell/rails4_0_strategy' if Cell.rails_version.~  "4.0"
    require 'cell/rails4_1_strategy' if Cell.rails_version >= "4.1"
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

    def self.class_from_cell_name(name)
      "#{name}_cell".classify.constantize
    end


    class << self
      # Main entry point for instantiating cells.
      def cell_for(name, *args)
        Builder.new(class_from_cell_name(name), self).call(*args)
      end

      alias_method :create_cell_for, :cell_for # TODO: remove us in 3.12.
      ActiveSupport::Deprecation.deprecate_methods(self, :create_cell_for => :cell_for)
    end

  private
    def process_args(*)
    end


    def self.view_context_class # DISCUSS: this is only needed for non-vm cells.
      @view_context_class ||= begin
        Cell::Base::View.prepare(helper_modules)
      end
    end

    def self.controller_path
      @controller_path ||= name.sub(/Cell$/, '').underscore unless anonymous?
    end


    require 'cell/base/view'
    require 'cell/base/prefixes'
    include Prefixes
    require 'cell/base/self_contained'
    extend SelfContained
  end

  autoload :ViewModel, 'cell/view_model'
  autoload :Concept,   'cell/concept'
end
