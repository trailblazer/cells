# TODO: merge into Rails core.
# TODO: cache _prefixes on class layer.
module Cell::Base::Prefixes
  extend ActiveSupport::Concern

  def _prefixes
    self.class._prefixes
  end

  module ClassMethods
    def _prefixes
      return [] if abstract?
      _local_prefixes + superclass._prefixes
    end

    def _local_prefixes
      [controller_path]
    end
  end
end