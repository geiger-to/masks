class AuthorizedController < ApplicationController
  attr_accessor :logged_in

  helper_method :client
  before_action :render_404, unless: :client

  helper_method :props_json

  class << self
    def managers_only(**opts)
      prepend_before_action(**opts) { self.client = Masks::Client.manage }

      authorized { authorization&.scopes&.include?(Masks::Scoped::MANAGE) }
    end

    def authorized(**opts, &block)
      before_action(**opts) do |controller|
        controller.logged_in = controller.instance_exec(&block)
      end

      before_action :redirect_to_login, **opts.merge(unless: :logged_in)
    end
  end

  private

  def props_json
    @props
      .deep_transform_keys do |key|
        key.to_s == "__typename" ? key : key.to_s.camelize(:lower)
      end
      .to_json
  end

  def client=(value)
    @client = value
  end

  def client
    @client
  end

  def authorization
    @authorization ||= nil
    # Masks::AuthorizationCode.active.where(client: client, device: device).last
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
