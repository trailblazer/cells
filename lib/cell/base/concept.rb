module Cell::Base::Concept
  def self.cell(name, controller, *args)
    Cell::Builder.new(name.classify.constantize, controller).cell_for(controller, *args)
  end

  module Naming
    module ClassMethods
      def controller_path
        # TODO: cache on class level
        # DISCUSS: only works with trailblazer style directories. this is a bit risky but i like it.
        # applies to Comment::Cell, Comment::Cell::Form, etc.
        name.sub(/::Cell/, '').underscore unless anonymous?
      end
    end
  end

  def self.included(base)
    base.extend Naming::ClassMethods # TODO: separate inherit_view
    base.self_contained!
  end
end