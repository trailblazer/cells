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
  let (:example_controller) { Object.new }

  it do
    cell = ParentCell.(model, admin: true, context: { user: user, controller: example_controller })
    # cell.extend(ParentController)

    cell.model.must_equal model
    cell.controller.must_equal example_controller
    cell.user.must_equal user

    # nested cell
    child = cell.cell("context_test/parent", "")

    child.model.must_equal ""
    child.controller.must_equal example_controller
    child.user.must_equal user
  end
end
