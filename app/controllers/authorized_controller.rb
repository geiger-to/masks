class AuthorizedController < ApplicationController
  attr_accessor :logged_in

  helper_method :client
  before_action :render_404, unless: :client
  before_action :verify_device, unless: :verified_device?

  delegate :authorization, to: :history

  class << self
    def authorized(&block)
      before_action do |controller|
        controller.logged_in = controller.instance_exec(&block)
      end

      before_action :redirect_to_login, unless: :logged_in
    end
  end

  private

  def client
    raise NotImplementedError
  end

  def redirect_to_login
    redirect_to authorize_path(client_id: client.key, redirect_uri: request.url)
  end

  def history
    @history ||= Masks::History.new(request:, device:, client:)
  end

  delegate :actor, to: :history

  def render_404
    @props = { section: "Error", code: 404 }

    render "app"
  end

  def verify_device
    render json: { device: "needs verification" }
  end

  def verified_device?
    device.known?
  end

  def device
    @device ||=
      Masks::Device.create_with(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
      ).find_or_create_by(session_id: session.id.to_s)
  end
end
