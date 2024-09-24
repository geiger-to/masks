class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :verify_device, unless: :verified_device?

  private

  def client
    raise NotImplementedError
  end

  def history
    @history ||= Masks::History.new(session_id: session.id, session:, device:)
  end

  def actor
    @actor ||= history.actor
  end

  def logged_in?
    history.authorized?(client)
  end

  def render_404
    @props = {
      section: 'Error',
      code: 404
    }

    render 'app'
  end

  def verify_device
    render json: { device: 'needs verification' }
  end

  def verified_device?
    device.known?
  end

  def device
    @device ||= begin
      device = if session[:device_key]
        Masks::Device.find_by(key: session[:device_key])
      end

      device ||= Masks::Device.create(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
      )

      session[:device_key] = device.key

      device
    end
  end
end
