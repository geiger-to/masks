module FrontendController
  extend ActiveSupport::Concern

  included do
    before_action :default_props
    helper_method :frontend_json
  end

  private

  def render_error(status:, **opts)
    settings = installation&.public_settings || {}
    frontend_props(backend: { settings:, prompt: "error" }.merge(opts))

    render "app", status:
  end

  def render_404
    render_error status: 404, error: "Not found"
  end

  def installation
    @installation ||= Masks.installation.reload
  end

  def default_props
    favicon = installation.favicon_url
    bg_dark = try(:client)&.bg_dark || installation.setting(:clients, :bg_dark)
    bg_light =
      try(:client)&.bg_light || installation.setting(:clients, :bg_light)

    frontend_props sentry:, bg_dark:, bg_light:, favicon:
  end

  def frontend_props(**updates)
    @frontend_props ||= {}
    @frontend_props.merge!(updates) if updates
    @frontend_props
  end

  def frontend_json
    @frontend_props
      .deep_transform_keys do |key|
        key.to_s == "__typename" ? key : key.to_s.camelize(:lower)
      end
      .to_json
  end

  def sentry
    @sentry ||= installation.setting(:integration, :sentry)
  end
end
