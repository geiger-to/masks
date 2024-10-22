module HistoryHelper
  def history_json(history = nil)
    result = history_result(history)
    client = result[:client]
    result[:client] = { id: client.key, name: client.name } if client

    result[:client][:logo] = rails_storage_proxy_url(
      client.logo.variant(:preview),
    ) if client&.logo&.attached?

    result
  end

  def history_result(history = nil)
    history ||= self.history
    client = history.client

    avatar =
      if history.actor&.avatar&.attached?
        rails_storage_proxy_url(history.actor.avatar.variant(:preview))
      end

    result = {
      client:,
      avatar:,
      nickname: history.nickname,
      authenticated: history.authenticated?,
      successful: history.successful?,
      settled: history.settled?,
      redirect_uri: history.redirect_uri,
      error_code: history.error,
      error_message: history.error ? t("auth.#{history.error}") : nil,
    }

    result.merge(prompt: history_prompt(history, result))
  end

  def history_prompt(history, json)
    return json[:error_code] if json[:error_code]

    return "success" if json[:successful]
    return "authorize" if json[:authenticated] && !history.authorized?
    return "password" if json[:nickname]

    "login"
  end
end
