class ManageController < ManagersController
  def index
    @theme = "luxury"
    @props = {
      section: "Manage",
      actor: actor.slice(:identicon_id, :nickname, :login_email, :avatar_url),
    }

    render "app"
  end
end
