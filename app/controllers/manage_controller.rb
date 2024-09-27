class ManageController < AuthorizedController
  before_action :redirect_to_login, unless: :logged_in?

  def index
    @theme = "luxury"
    @props = { section: "Manage", nickname: actor.nickname }

    render "app"
  end

  private

  def redirect_to_login
    redirect_to authorize_path(client_id: client.key, redirect_uri: request.url)
  end

  def client
    @client ||= Masks::Client.manage
  end

  def logged_in?
    super && actor.scopes.include?(Masks::Scoped::MANAGE)
  end
end
