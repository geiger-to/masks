class ManageController < ManagersController
  def index
    @theme = "luxury"
    @props = {
      section: "Manage",
      url: params[:url] || "",
      install: installation.public_settings,
      device: {
        id: device.public_id,
      },
      sentry:,
      actor:
        current_manager.slice(:identifier, :identicon_id, :avatar_url).merge(
          id: current_manager.key,
        ),
    }

    render "manage"
  end
end
