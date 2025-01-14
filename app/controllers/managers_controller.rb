class ManagersController < ApplicationController
  include Masks::InternalController
  include FrontendController

  before_action :render_404, unless: :client
  before_action :redirect_to_login, unless: :current_manager

  private

  def client
    Masks::Client.manage
  end

  def redirect_to_login
    redirect_to authorize_path(
                  client_id: client.key,
                  redirect_uri: request.path,
                )
  end
end
