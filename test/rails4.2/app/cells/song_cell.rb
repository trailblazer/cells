class SongCell < Cell::ViewModel
  include Escaped
  property :title

  def show
    "happy"
  end

  def with_escaped
    render
  end
  # include ActionView::Helpers::AssetUrlHelper
  # include Sprockets::Rails::Helper

  # self.assets_prefix = Rails.application.config.assets.prefix
  # self.assets_environment = Rails.application.assets
  # self.digest_assets = Rails.application.config.assets[:digest]
end