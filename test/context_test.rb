require "test_helper"

class ContextTest < MiniTest::Spec
  class ParentCell < Cell::ViewModel

  end

  let (:model) { Object.new }
  let (:user) { Object.new }
  let (:controller) { Object.new }

  it do
    cell = ParentCell.(model, admin: true, context: { user: user, controller: controller })

    # cell.extend(ParentController)

    cell.model.must_equal model

    cell.controller.must_equal controller
    cell.send(:options)[:context][:user].must_equal user
  end

end
