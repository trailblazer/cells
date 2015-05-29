# TODO: cache _prefixes on class layer.
module Cell::Prefixes
  extend ActiveSupport::Concern

  def _prefixes
    self.class._prefixes
  end

  # You're free to override those methods in case you want to alter our view inheritance.
  module ClassMethods
    def _prefixes
      return [] if abstract?
      _local_prefixes + superclass._prefixes
    end

    def _local_prefixes
      view_paths.collect { |path| "#{path}/#{controller_path}" }
    end

    # Instructs Cells to inherit views from a parent cell without having to inherit class code.
    def inherit_views(parent)
      define_method :_prefixes do
        super() + parent._prefixes
      end
    end
  end
end