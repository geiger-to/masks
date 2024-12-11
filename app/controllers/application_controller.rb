class ApplicationController < ActionController::Base
  attr_accessor :client

  before_action :set_favicon

  around_action { |controller, block| internal_session.auth!(&block) }

  helper_method :props_json

  private

  def auth
    @auth ||= Masks::Auth.new(request:, client:)
  end

  def internal_session
    @internal_session ||= Masks::InternalSession.new(auth:)
  end

  delegate :current_actor, :device, to: :internal_session

  def props_json
    @props
      .deep_transform_keys do |key|
        key.to_s == "__typename" ? key : key.to_s.camelize(:lower)
      end
      .to_json
  end

  def set_favicon
    @favicon = installation.favicon_url
  end

  def installation
    @installation ||= Masks.installation.reload
  end
end
