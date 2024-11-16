class ManagersController < ApplicationController
  attr_accessor :logged_in, :client

  before_action :render_404, unless: :client

  around_action { |controller, block| auth.session!(&block) }

  before_action :redirect_to_login, unless: :actor

  private

  def auth
    @auth ||= Masks::Auth.new(request:, client:)
  end

  def internal_session
    @internal_session = auth.prompt_for(Masks::Prompts::InternalSession)
  end

  def actor
    internal_session.current_actor
  end

  delegate :device, to: :auth

  def client
    Masks::Client.manage
  end

  def redirect_to_login
    redirect_to authorize_path(
                  client_id: client.key,
                  redirect_uri: request.path,
                )
  end

  def render_404
    @props = { section: "Error", code: 404 }

    render "app", status: 404
  end
end
