class ManageController < ManagersController
  def index
    @theme = "luxury"
    @props = {
      section: "Manage",
      url: params[:url] || "",
      actor:
        current_actor.slice(:identifier, :identicon_id, :avatar_url).merge(
          id: current_actor.key,
        ),
    }

    render "manage"
  end
end
