class ManageController < AuthorizedController
  delegate :actor, to: :authorization, allow_nil: true

  authorized { actor && authorization&.scopes&.include?(Masks::Scoped::MANAGE) }

  def index
    @theme = "luxury"
    @props = { section: "Manage", nickname: actor.nickname }

    render "app"
  end

  private

  def client
    @client ||= Masks::Client.manage
  end
end
