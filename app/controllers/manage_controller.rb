class ManageController < AuthorizedController
  delegate :actor, to: :authorization, allow_nil: true

  managers_only

  def index
    @theme = "luxury"
    @props = { section: "Manage", nickname: actor.nickname }

    render "app"
  end
end
