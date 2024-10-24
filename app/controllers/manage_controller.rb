class ManageController < AuthorizedController
  delegate :actor, to: :authorization, allow_nil: true

  managers_only

  def index
    @theme = "luxury"
    @props = {
      section: "Manage",
      actor: actor.slice(:identicon_id, :nickname, :login_email, :avatar_url),
    }

    render "app"
  end
end
