class ProvidersController < ApplicationController
  include Masks::InternalController
  include FrontendController

  def callback
    provider = Masks::Provider.enabled.find_by(key: params[:provider_id])

    raise "invalid-sso" unless provider

    state = auth.prompt_for(Masks::Prompts::SingleSignOn).state_bag

    raise "invalid-sso" unless state && state["provider"] == provider.key

    auth.update!(
      id: state["attempt"],
      event: "sso:callback",
      updates: {
        provider:,
      },
      resume: true,
    )

    redirect_to state["origin"]
  rescue => e
    render_error(
      status: 404,
      prompt: "sso-error",
      error: e.to_s,
      origin: state&.dig("origin"),
      provider:
        provider ? { name: provider&.name, type: provider&.public_type } : nil,
    )
  end
end
