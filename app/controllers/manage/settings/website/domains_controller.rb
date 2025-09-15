class Manage::Settings::Website::DomainsController < Manage::BaseController
  before_action :set_website, only: [:index]
  def index
  end

  private

  def set_website
    @website = current_user.website
  end
end
