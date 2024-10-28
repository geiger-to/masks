module HistoryHelper
  def history_json(history = nil)
    result = history_result(history)
    client = result[:client]
    actor = result[:actor]

    result[:client] = { id: client.key, name: client.name } if client
    result[:client][:logo] = rails_storage_proxy_url(
      client.logo.variant(:preview),
    ) if client&.logo&.attached?

    result[:actor] = {
      id: actor.key,
      name: actor.name,
      nickname: actor.nickname,
      identicon_id: actor.identicon_id,
      identifier: actor.identifier,
      identifier_type: actor.identifier_type,
      login_email: actor.login_email&.address,
      avatar: actor.avatar_url,
      avatar_created_at: actor.avatar_created_at,
    } if actor

    result[:actor][:avatar] = rails_storage_proxy_url(
      actor.avatar.variant(:preview),
    ) if actor&.avatar&.attached?

    result
  end

  def history_result(history = nil)
    history ||= self.history
    client = history.client
    actor = history.actor

    result = {
      client:,
      avatar: history&.actor&.avatar_url,
      identicon_id: history.actor&.identicon_id,
      identifier: history.identifier,
      authenticated: history.authenticated?,
      successful: history.successful?,
      redirect_uri: history.redirect_uri,
      error_code: history.error,
      error_message: history.error ? t("auth.#{history.error}") : nil,
      settings: Masks.installation.public_settings,
    }

    onboarded = actor&.onboarded?
    settled =
      (history.successful? && onboarded) ||
        (history.redirect_uri && history.oidc_error?)
    prompt =
      if result[:error_code]
        result[:error_code]
      elsif result[:successful] && !actor.onboarded?
        "onboard"
      elsif result[:successful]
        "success"
      elsif result[:authenticated] && !history.authorized?
        "authorize"
      elsif result[:identifier]
        "password"
      else
        "login"
      end

    result.merge(prompt:, settled:, actor: history.authenticated? ? actor : nil)
  end
end
