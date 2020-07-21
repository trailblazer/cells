require "test_helper"

class ContextTest < MiniTest::Spec
  class ParentCell < Cell::ViewModel
    def user
      context[:user]
    end

    def controller
      context[:controller]
    end
  end

  let (:model) { Object.new }
  let (:user) { Object.new }
  let (:controller) { Object.new }

  let (:parent) { ParentCell.(model, admin: true, context: { user: user, controller: controller }) }

  it do
    _(parent.model).must_equal model
    _(parent.controller).must_equal controller
    _(parent.user).must_equal user

    # nested cell
    child = parent.cell("context_test/parent", "")

    _(child.model).must_equal ""
    _(child.controller).must_equal controller
    _(child.user).must_equal user
  end

  # child can add to context
  it do
    child = parent.cell(ParentCell, nil, context: { "is_child?" => true })

    assert_nil(parent.context["is_child?"])

    assert_nil(child.model)
    _(child.controller).must_equal controller
    _(child.user).must_equal user
    _(child.context["is_child?"]).must_equal true
  end
end
