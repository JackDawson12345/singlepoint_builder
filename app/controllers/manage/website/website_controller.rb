class Manage::Website::WebsiteController <  Manage::BaseController

  def index
    @themes = Theme.all
  end

end
