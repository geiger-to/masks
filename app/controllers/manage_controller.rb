class ManageController < ManagersController
  def index
    @theme = "luxury"
    @props = {
      section: "Manage",
      url: params[:url] || "",
      actor: current_actor.slice(:identifier, :identicon_id, :avatar_url),
    }

    render "manage"
  end
end
