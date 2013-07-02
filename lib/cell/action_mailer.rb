require 'cell/base'

module Cell
  # Use Cell::ActionMailer in Rails ActionMailer.
  # This allows helpers such as asset_path() or image_tag() to use assets full
  # url (if config.asset_host is set properly).
  # Remember to set default_url_options explictly in your cell to link_to()
  # outputs full urls too.
  class ActionMailer < Base
    delegate :config, :env, :url_options, :to => :parent_controller

    attr_reader :parent_controller
    alias_method :controller, :parent_controller

    class << self
      def create_cell(controller, *args)
        new(controller)
      end
    end

    def initialize(parent_controller)
      super()
      @parent_controller = parent_controller
    end
  end
end
